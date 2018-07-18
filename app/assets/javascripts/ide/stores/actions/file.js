import { __ } from '../../../locale';
import { normalizeHeaders } from '../../../lib/utils/common_utils';
import eventHub from '../../eventhub';
import service from '../../services';
import * as types from '../mutation_types';
import router from '../../ide_router';
import { setPageTitle } from '../utils';
import { viewerTypes } from '../../constants';

export const closeFile = ({ commit, state, dispatch }, file) => {
  const { path } = file;
  const indexOfClosedFile = state.openFiles.findIndex(f => f.key === file.key);
  const fileWasActive = file.active;

  if (file.pending) {
    commit(types.REMOVE_PENDING_TAB, file);
  } else {
    commit(types.TOGGLE_FILE_OPEN, path);
    commit(types.SET_FILE_ACTIVE, { path, active: false });
  }

  if (state.openFiles.length > 0 && fileWasActive) {
    const nextIndexToOpen = indexOfClosedFile === 0 ? 0 : indexOfClosedFile - 1;
    const nextFileToOpen = state.openFiles[nextIndexToOpen];

    if (nextFileToOpen.pending) {
      dispatch('updateViewer', viewerTypes.diff);
      dispatch('openPendingTab', {
        file: nextFileToOpen,
        keyPrefix: nextFileToOpen.staged ? 'staged' : 'unstaged',
      });
    } else {
      router.push(`/project${nextFileToOpen.url}`);
    }
  } else if (!state.openFiles.length) {
    router.push(`/project/${file.projectId}/tree/${file.branchId}/`);
  }

  eventHub.$emit(`editor.update.model.dispose.${file.key}`);
};

export const setFileActive = ({ commit, state, getters, dispatch }, path) => {
  const file = state.entries[path];
  const currentActiveFile = getters.activeFile;

  if (file.active) return;

  if (currentActiveFile) {
    commit(types.SET_FILE_ACTIVE, {
      path: currentActiveFile.path,
      active: false,
    });
  }

  commit(types.SET_FILE_ACTIVE, { path, active: true });
  dispatch('scrollToTab');

  commit(types.SET_CURRENT_PROJECT, file.projectId);
  commit(types.SET_CURRENT_BRANCH, file.branchId);
};

export const getFileData = ({ state, commit, dispatch }, { path, makeFileActive = true }) => {
  const file = state.entries[path];
  commit(types.TOGGLE_LOADING, { entry: file });
  return service
    .getFileData(
      `${gon.relative_url_root ? gon.relative_url_root : ''}${file.url.replace('/-/', '/')}`,
    )
    .then(({ data, headers }) => {
      const normalizedHeaders = normalizeHeaders(headers);
      setPageTitle(decodeURI(normalizedHeaders['PAGE-TITLE']));

      commit(types.SET_FILE_DATA, { data, file });
      commit(types.TOGGLE_FILE_OPEN, path);
      if (makeFileActive) dispatch('setFileActive', path);
      commit(types.TOGGLE_LOADING, { entry: file });
    })
    .catch(() => {
      commit(types.TOGGLE_LOADING, { entry: file });
      dispatch('setErrorMessage', {
        text: __('An error occured whilst loading the file.'),
        action: payload =>
          dispatch('getFileData', payload).then(() => dispatch('setErrorMessage', null)),
        actionText: __('Please try again'),
        actionPayload: { path, makeFileActive },
      });
    });
};

export const setFileMrChange = ({ commit }, { file, mrChange }) => {
  commit(types.SET_FILE_MERGE_REQUEST_CHANGE, { file, mrChange });
};

export const getRawFileData = ({ state, commit, dispatch }, { path, baseSha }) => {
  const file = state.entries[path];
  return new Promise((resolve, reject) => {
    service
      .getRawFileData(file)
      .then(raw => {
        commit(types.SET_FILE_RAW_DATA, { file, raw });
        if (file.mrChange && file.mrChange.new_file === false) {
          service
            .getBaseRawFileData(file, baseSha)
            .then(baseRaw => {
              commit(types.SET_FILE_BASE_RAW_DATA, {
                file,
                baseRaw,
              });
              resolve(raw);
            })
            .catch(e => {
              reject(e);
            });
        } else {
          resolve(raw);
        }
      })
      .catch(() => {
        dispatch('setErrorMessage', {
          text: __('An error occured whilst loading the file content.'),
          action: payload =>
            dispatch('getRawFileData', payload).then(() => dispatch('setErrorMessage', null)),
          actionText: __('Please try again'),
          actionPayload: { path, baseSha },
        });
        reject();
      });
  });
};

export const changeFileContent = ({ commit, dispatch, state }, { path, content }) => {
  const file = state.entries[path];
  commit(types.UPDATE_FILE_CONTENT, { path, content });

  const indexOfChangedFile = state.changedFiles.findIndex(f => f.path === path);

  if (file.changed && indexOfChangedFile === -1) {
    commit(types.ADD_FILE_TO_CHANGED, path);
  } else if (!file.changed && indexOfChangedFile !== -1) {
    commit(types.REMOVE_FILE_FROM_CHANGED, path);
  }

  dispatch('burstUnusedSeal', {}, { root: true });
};

export const setFileLanguage = ({ getters, commit }, { fileLanguage }) => {
  if (getters.activeFile) {
    commit(types.SET_FILE_LANGUAGE, { file: getters.activeFile, fileLanguage });
  }
};

export const setFileEOL = ({ getters, commit }, { eol }) => {
  if (getters.activeFile) {
    commit(types.SET_FILE_EOL, { file: getters.activeFile, eol });
  }
};

export const setEditorPosition = ({ getters, commit }, { editorRow, editorColumn }) => {
  if (getters.activeFile) {
    commit(types.SET_FILE_POSITION, {
      file: getters.activeFile,
      editorRow,
      editorColumn,
    });
  }
};

export const setFileViewMode = ({ commit }, { file, viewMode }) => {
  commit(types.SET_FILE_VIEWMODE, { file, viewMode });
};

export const discardFileChanges = ({ dispatch, state, commit, getters }, path) => {
  const file = state.entries[path];

  commit(types.DISCARD_FILE_CHANGES, path);
  commit(types.REMOVE_FILE_FROM_CHANGED, path);

  if (file.tempFile && file.opened) {
    commit(types.TOGGLE_FILE_OPEN, path);
  } else if (getters.activeFile && file.path === getters.activeFile.path) {
    dispatch('updateDelayViewerUpdated', true)
      .then(() => {
        router.push(`/project${file.url}`);
      })
      .catch(e => {
        throw e;
      });
  }

  eventHub.$emit(`editor.update.model.new.content.${file.key}`, file.content);
  eventHub.$emit(`editor.update.model.dispose.unstaged-${file.key}`, file.content);
};

export const stageChange = ({ commit, state }, path) => {
  const stagedFile = state.stagedFiles.find(f => f.path === path);

  commit(types.STAGE_CHANGE, path);
  commit(types.SET_LAST_COMMIT_MSG, '');

  if (stagedFile) {
    eventHub.$emit(`editor.update.model.new.content.staged-${stagedFile.key}`, stagedFile.content);
  }
};

export const unstageChange = ({ commit }, path) => {
  commit(types.UNSTAGE_CHANGE, path);
};

export const openPendingTab = ({ commit, getters, dispatch, state }, { file, keyPrefix }) => {
  if (getters.activeFile && getters.activeFile.key === `${keyPrefix}-${file.key}`) return false;

  state.openFiles.forEach(f => eventHub.$emit(`editor.update.model.dispose.${f.key}`));

  commit(types.ADD_PENDING_TAB, { file, keyPrefix });

  dispatch('scrollToTab');

  router.push(`/project/${file.projectId}/tree/${state.currentBranchId}/`);

  return true;
};

export const removePendingTab = ({ commit }, file) => {
  commit(types.REMOVE_PENDING_TAB, file);

  eventHub.$emit(`editor.update.model.dispose.${file.key}`);
};
