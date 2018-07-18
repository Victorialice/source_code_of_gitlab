import Vue from 'vue';
import VueRouter from 'vue-router';
import flash from '~/flash';
import store from './stores';
import { activityBarViews } from './constants';

Vue.use(VueRouter);

/**
 * Routes below /-/ide/:

/project/h5bp/html5-boilerplate/blob/master
/project/h5bp/html5-boilerplate/blob/master/app/js/test.js

/project/h5bp/html5-boilerplate/mr/123
/project/h5bp/html5-boilerplate/mr/123/app/js/test.js

/workspace/123
/workspace/project/h5bp/html5-boilerplate/blob/my-special-branch
/workspace/project/h5bp/html5-boilerplate/mr/123

/ = /workspace

/settings
*/

// Unfortunately Vue Router doesn't work without at least a fake component
// If you do only data handling
const EmptyRouterComponent = {
  render(createElement) {
    return createElement('div');
  },
};

const router = new VueRouter({
  mode: 'history',
  base: `${gon.relative_url_root}/-/ide/`,
  routes: [
    {
      path: '/project/:namespace/:project+',
      component: EmptyRouterComponent,
      children: [
        {
          path: ':targetmode(edit|tree|blob)/*',
          component: EmptyRouterComponent,
        },
        {
          path: 'merge_requests/:mrid',
          component: EmptyRouterComponent,
        },
      ],
    },
  ],
});

router.beforeEach((to, from, next) => {
  if (to.params.namespace && to.params.project) {
    store
      .dispatch('getProjectData', {
        namespace: to.params.namespace,
        projectId: to.params.project,
      })
      .then(() => {
        const fullProjectId = `${to.params.namespace}/${to.params.project}`;

        const baseSplit = (to.params[0] && to.params[0].split('/-/')) || [''];
        const branchId = baseSplit[0].slice(-1) === '/' ? baseSplit[0].slice(0, -1) : baseSplit[0];

        if (branchId) {
          const basePath = baseSplit.length > 1 ? baseSplit[1] : '';

          store.dispatch('setCurrentBranchId', branchId);

          store.dispatch('getBranchData', {
            projectId: fullProjectId,
            branchId,
          });

          store
            .dispatch('getFiles', {
              projectId: fullProjectId,
              branchId,
            })
            .then(() => {
              if (basePath) {
                const path = basePath.slice(-1) === '/' ? basePath.slice(0, -1) : basePath;
                const treeEntryKey = Object.keys(store.state.entries).find(
                  key => key === path && !store.state.entries[key].pending,
                );
                const treeEntry = store.state.entries[treeEntryKey];

                if (treeEntry) {
                  store.dispatch('handleTreeEntryAction', treeEntry);
                }
              }
            })
            .catch(e => {
              throw e;
            });
        } else if (to.params.mrid) {
          store
            .dispatch('getMergeRequestData', {
              projectId: fullProjectId,
              targetProjectId: to.query.target_project,
              mergeRequestId: to.params.mrid,
            })
            .then(mr => {
              store.dispatch('updateActivityBarView', activityBarViews.review);

              store.dispatch('getBranchData', {
                projectId: fullProjectId,
                branchId: mr.source_branch,
              });

              return store.dispatch('getFiles', {
                projectId: fullProjectId,
                branchId: mr.source_branch,
              });
            })
            .then(() =>
              store.dispatch('getMergeRequestVersions', {
                projectId: fullProjectId,
                targetProjectId: to.query.target_project,
                mergeRequestId: to.params.mrid,
              }),
            )
            .then(() =>
              store.dispatch('getMergeRequestChanges', {
                projectId: fullProjectId,
                targetProjectId: to.query.target_project,
                mergeRequestId: to.params.mrid,
              }),
            )
            .then(mrChanges => {
              mrChanges.changes.forEach((change, ind) => {
                const changeTreeEntry = store.state.entries[change.new_path];

                if (changeTreeEntry) {
                  store.dispatch('setFileMrChange', {
                    file: changeTreeEntry,
                    mrChange: change,
                  });

                  if (ind < 10) {
                    store.dispatch('getFileData', {
                      path: change.new_path,
                      makeFileActive: ind === 0,
                    });
                  }
                }
              });
            })
            .catch(e => {
              flash('Error while loading the merge request. Please try again.');
              throw e;
            });
        }
      })
      .catch(e => {
        flash(
          'Error while loading the project data. Please try again.',
          'alert',
          document,
          null,
          false,
          true,
        );
        throw e;
      });
  }

  next();
});

export default router;
