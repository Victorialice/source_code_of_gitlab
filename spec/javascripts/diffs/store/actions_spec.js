import MockAdapter from 'axios-mock-adapter';
import Cookies from 'js-cookie';
import {
  DIFF_VIEW_COOKIE_NAME,
  INLINE_DIFF_VIEW_TYPE,
  PARALLEL_DIFF_VIEW_TYPE,
} from '~/diffs/constants';
import * as actions from '~/diffs/store/actions';
import * as types from '~/diffs/store/mutation_types';
import axios from '~/lib/utils/axios_utils';
import testAction from '../../helpers/vuex_action_helper';

describe('DiffsStoreActions', () => {
  describe('setBaseConfig', () => {
    it('should set given endpoint and project path', done => {
      const endpoint = '/diffs/set/endpoint';
      const projectPath = '/root/project';

      testAction(
        actions.setBaseConfig,
        { endpoint, projectPath },
        { endpoint: '', projectPath: '' },
        [{ type: types.SET_BASE_CONFIG, payload: { endpoint, projectPath } }],
        [],
        done,
      );
    });
  });

  describe('fetchDiffFiles', () => {
    it('should fetch diff files', done => {
      const endpoint = '/fetch/diff/files';
      const mock = new MockAdapter(axios);
      const res = { diff_files: 1, merge_request_diffs: [] };
      mock.onGet(endpoint).reply(200, res);

      testAction(
        actions.fetchDiffFiles,
        {},
        { endpoint },
        [
          { type: types.SET_LOADING, payload: true },
          { type: types.SET_LOADING, payload: false },
          { type: types.SET_MERGE_REQUEST_DIFFS, payload: res.merge_request_diffs },
          { type: types.SET_DIFF_DATA, payload: res },
        ],
        [],
        () => {
          mock.restore();
          done();
        },
      );
    });
  });

  describe('setInlineDiffViewType', () => {
    it('should set diff view type to inline and also set the cookie properly', done => {
      testAction(
        actions.setInlineDiffViewType,
        null,
        {},
        [{ type: types.SET_DIFF_VIEW_TYPE, payload: INLINE_DIFF_VIEW_TYPE }],
        [],
        () => {
          setTimeout(() => {
            expect(Cookies.get('diff_view')).toEqual(INLINE_DIFF_VIEW_TYPE);
            done();
          }, 0);
        },
      );
    });
  });

  describe('setParallelDiffViewType', () => {
    it('should set diff view type to parallel and also set the cookie properly', done => {
      testAction(
        actions.setParallelDiffViewType,
        null,
        {},
        [{ type: types.SET_DIFF_VIEW_TYPE, payload: PARALLEL_DIFF_VIEW_TYPE }],
        [],
        () => {
          setTimeout(() => {
            expect(Cookies.get(DIFF_VIEW_COOKIE_NAME)).toEqual(PARALLEL_DIFF_VIEW_TYPE);
            done();
          }, 0);
        },
      );
    });
  });

  describe('showCommentForm', () => {
    it('should call mutation to show comment form', done => {
      const payload = { lineCode: 'lineCode' };

      testAction(
        actions.showCommentForm,
        payload,
        {},
        [{ type: types.ADD_COMMENT_FORM_LINE, payload }],
        [],
        done,
      );
    });
  });

  describe('cancelCommentForm', () => {
    it('should call mutation to cancel comment form', done => {
      const payload = { lineCode: 'lineCode' };

      testAction(
        actions.cancelCommentForm,
        payload,
        {},
        [{ type: types.REMOVE_COMMENT_FORM_LINE, payload }],
        [],
        done,
      );
    });
  });

  describe('loadMoreLines', () => {
    it('should call mutation to show comment form', done => {
      const endpoint = '/diffs/load/more/lines';
      const params = { since: 6, to: 26 };
      const lineNumbers = { oldLineNumber: 3, newLineNumber: 5 };
      const fileHash = 'ff9200';
      const options = { endpoint, params, lineNumbers, fileHash };
      const mock = new MockAdapter(axios);
      const contextLines = { contextLines: [{ lineCode: 6 }] };
      mock.onGet(endpoint).reply(200, contextLines);

      testAction(
        actions.loadMoreLines,
        options,
        {},
        [
          {
            type: types.ADD_CONTEXT_LINES,
            payload: { lineNumbers, contextLines, params, fileHash },
          },
        ],
        [],
        () => {
          mock.restore();
          done();
        },
      );
    });
  });

  describe('loadCollapsedDiff', () => {
    it('should fetch data and call mutation with response and the give parameter', done => {
      const file = { hash: 123, loadCollapsedDiffUrl: '/load/collapsed/diff/url' };
      const data = { hash: 123, parallelDiffLines: [{ lineCode: 1 }] };
      const mock = new MockAdapter(axios);
      mock.onGet(file.loadCollapsedDiffUrl).reply(200, data);

      testAction(
        actions.loadCollapsedDiff,
        file,
        {},
        [
          {
            type: types.ADD_COLLAPSED_DIFFS,
            payload: { file, data },
          },
        ],
        [],
        () => {
          mock.restore();
          done();
        },
      );
    });
  });

  describe('expandAllFiles', () => {
    it('should change the collapsed prop from the diffFiles', done => {
      testAction(
        actions.expandAllFiles,
        null,
        {},
        [
          {
            type: types.EXPAND_ALL_FILES,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('toggleFileDiscussions', () => {
    it('should dispatch collapseDiscussion when all discussions are expanded', () => {
      const getters = {
        getDiffFileDiscussions: jasmine.createSpy().and.returnValue([{ id: 1 }]),
        diffHasAllExpandedDiscussions: jasmine.createSpy().and.returnValue(true),
        diffHasAllCollpasedDiscussions: jasmine.createSpy().and.returnValue(false),
      };

      const dispatch = jasmine.createSpy('dispatch');

      actions.toggleFileDiscussions({ getters, dispatch });

      expect(dispatch).toHaveBeenCalledWith('collapseDiscussion', { discussionId: 1 }, { root: true });
    });

    it('should dispatch expandDiscussion when all discussions are collapsed', () => {
      const getters = {
        getDiffFileDiscussions: jasmine.createSpy().and.returnValue([{ id: 1 }]),
        diffHasAllExpandedDiscussions: jasmine.createSpy().and.returnValue(false),
        diffHasAllCollpasedDiscussions: jasmine.createSpy().and.returnValue(true),
      };

      const dispatch = jasmine.createSpy();

      actions.toggleFileDiscussions({ getters, dispatch });

      expect(dispatch).toHaveBeenCalledWith('expandDiscussion', { discussionId: 1 }, { root: true });
    });

    it('should dispatch expandDiscussion when some discussions are collapsed and others are expanded for the collapsed discussion', () => {
      const getters = {
        getDiffFileDiscussions: jasmine.createSpy().and.returnValue([{ expanded: false, id: 1 }]),
        diffHasAllExpandedDiscussions: jasmine.createSpy().and.returnValue(false),
        diffHasAllCollpasedDiscussions: jasmine.createSpy().and.returnValue(false),
      };

      const dispatch = jasmine.createSpy();

      actions.toggleFileDiscussions({ getters, dispatch });

      expect(dispatch).toHaveBeenCalledWith('expandDiscussion', { discussionId: 1 }, { root: true });
    });
  });
});
