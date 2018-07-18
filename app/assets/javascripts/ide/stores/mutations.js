import * as types from './mutation_types';
import projectMutations from './mutations/project';
import mergeRequestMutation from './mutations/merge_request';
import fileMutations from './mutations/file';
import treeMutations from './mutations/tree';
import branchMutations from './mutations/branch';
import { sortTree } from './utils';

export default {
  [types.SET_INITIAL_DATA](state, data) {
    Object.assign(state, data);
  },
  [types.TOGGLE_LOADING](state, { entry, forceValue = undefined }) {
    if (entry.path) {
      Object.assign(state.entries[entry.path], {
        loading: forceValue !== undefined ? forceValue : !state.entries[entry.path].loading,
      });
    } else {
      Object.assign(entry, {
        loading: forceValue !== undefined ? forceValue : !entry.loading,
      });
    }
  },
  [types.SET_LEFT_PANEL_COLLAPSED](state, collapsed) {
    Object.assign(state, {
      leftPanelCollapsed: collapsed,
    });
  },
  [types.SET_RIGHT_PANEL_COLLAPSED](state, collapsed) {
    Object.assign(state, {
      rightPanelCollapsed: collapsed,
    });
  },
  [types.SET_RESIZING_STATUS](state, resizing) {
    Object.assign(state, {
      panelResizing: resizing,
    });
  },
  [types.SET_LAST_COMMIT_DATA](state, { entry, lastCommit }) {
    Object.assign(entry.lastCommit, {
      id: lastCommit.commit.id,
      url: lastCommit.commit_path,
      message: lastCommit.commit.message,
      author: lastCommit.commit.author_name,
      updatedAt: lastCommit.commit.authored_date,
    });
  },
  [types.SET_LAST_COMMIT_MSG](state, lastCommitMsg) {
    Object.assign(state, {
      lastCommitMsg,
    });
  },
  [types.CLEAR_STAGED_CHANGES](state) {
    Object.assign(state, {
      stagedFiles: [],
    });
  },
  [types.SET_ENTRIES](state, entries) {
    Object.assign(state, {
      entries,
    });
  },
  [types.CREATE_TMP_ENTRY](state, { data, projectId, branchId }) {
    Object.keys(data.entries).reduce((acc, key) => {
      const entry = data.entries[key];
      const foundEntry = state.entries[key];

      if (!foundEntry) {
        Object.assign(state.entries, {
          [key]: entry,
        });
      } else {
        const tree = entry.tree.filter(
          f => foundEntry.tree.find(e => e.path === f.path) === undefined,
        );
        Object.assign(foundEntry, {
          tree: sortTree(foundEntry.tree.concat(tree)),
        });
      }

      return acc.concat(key);
    }, []);

    const foundEntry = state.trees[`${projectId}/${branchId}`].tree.find(
      e => e.path === data.treeList[0].path,
    );

    if (!foundEntry) {
      Object.assign(state.trees[`${projectId}/${branchId}`], {
        tree: sortTree(state.trees[`${projectId}/${branchId}`].tree.concat(data.treeList)),
      });
    }
  },
  [types.UPDATE_TEMP_FLAG](state, { path, tempFile }) {
    Object.assign(state.entries[path], {
      tempFile,
      changed: tempFile,
    });
  },
  [types.UPDATE_VIEWER](state, viewer) {
    Object.assign(state, {
      viewer,
    });
  },
  [types.UPDATE_DELAY_VIEWER_CHANGE](state, delayViewerUpdated) {
    Object.assign(state, {
      delayViewerUpdated,
    });
  },
  [types.UPDATE_ACTIVITY_BAR_VIEW](state, currentActivityView) {
    Object.assign(state, {
      currentActivityView,
    });
  },
  [types.SET_EMPTY_STATE_SVGS](
    state,
    { emptyStateSvgPath, noChangesStateSvgPath, committedStateSvgPath, pipelinesEmptyStateSvgPath },
  ) {
    Object.assign(state, {
      emptyStateSvgPath,
      noChangesStateSvgPath,
      committedStateSvgPath,
      pipelinesEmptyStateSvgPath,
    });
  },
  [types.TOGGLE_FILE_FINDER](state, fileFindVisible) {
    Object.assign(state, {
      fileFindVisible,
    });
  },
  [types.UPDATE_FILE_AFTER_COMMIT](state, { file, lastCommit }) {
    const changedFile = state.changedFiles.find(f => f.path === file.path);

    Object.assign(state.entries[file.path], {
      raw: file.content,
      changed: !!changedFile,
      staged: false,
      lastCommit: Object.assign(state.entries[file.path].lastCommit, {
        id: lastCommit.commit.id,
        url: lastCommit.commit_path,
        message: lastCommit.commit.message,
        author: lastCommit.commit.author_name,
        updatedAt: lastCommit.commit.authored_date,
      }),
    });
  },
  [types.BURST_UNUSED_SEAL](state) {
    Object.assign(state, {
      unusedSeal: false,
    });
  },
  [types.SET_RIGHT_PANE](state, view) {
    Object.assign(state, {
      rightPane: state.rightPane === view ? null : view,
    });
  },
  [types.SET_LINKS](state, links) {
    Object.assign(state, { links });
  },
  [types.CLEAR_PROJECTS](state) {
    Object.assign(state, { projects: {}, trees: {} });
  },
  [types.RESET_OPEN_FILES](state) {
    Object.assign(state, { openFiles: [] });
  },
  [types.SET_ERROR_MESSAGE](state, errorMessage) {
    Object.assign(state, { errorMessage });
  },
  [types.OPEN_NEW_ENTRY_MODAL](state, { type, path }) {
    Object.assign(state, {
      newEntryModal: { type, path },
    });
  },
  ...projectMutations,
  ...mergeRequestMutation,
  ...fileMutations,
  ...treeMutations,
  ...branchMutations,
};
