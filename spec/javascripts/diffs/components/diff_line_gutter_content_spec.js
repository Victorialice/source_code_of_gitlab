import Vue from 'vue';
import DiffLineGutterContent from '~/diffs/components/diff_line_gutter_content.vue';
import store from '~/mr_notes/stores';
import { createComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import discussionsMockData from '../mock_data/diff_discussions';
import diffFileMockData from '../mock_data/diff_file';

describe('DiffLineGutterContent', () => {
  const getDiscussionsMockData = () => [Object.assign({}, discussionsMockData)];
  const getDiffFileMock = () => Object.assign({}, diffFileMockData);
  const createComponent = (options = {}) => {
    const cmp = Vue.extend(DiffLineGutterContent);
    const props = Object.assign({}, options);
    props.fileHash = getDiffFileMock().fileHash;
    props.contextLinesPath = '/context/lines/path';

    return createComponentWithStore(cmp, store, props).$mount();
  };
  const setDiscussions = component => {
    component.$store.dispatch('setInitialNotes', getDiscussionsMockData());
  };

  const resetDiscussions = component => {
    component.$store.dispatch('setInitialNotes', []);
  };

  describe('computed', () => {
    describe('lineHref', () => {
      it('should prepend # to lineCode', () => {
        const lineCode = 'LC_42';
        const component = createComponent({ lineCode });
        expect(component.lineHref).toEqual(`#${lineCode}`);
      });

      it('should return # if there is no lineCode', () => {
        const component = createComponent({ lineCode: null });
        expect(component.lineHref).toEqual('#');
      });
    });

    describe('discussions, hasDiscussions, shouldShowAvatarsOnGutter', () => {
      it('should return empty array when there is no discussion', () => {
        const component = createComponent({ lineCode: 'LC_42' });
        expect(component.discussions).toEqual([]);
        expect(component.hasDiscussions).toEqual(false);
        expect(component.shouldShowAvatarsOnGutter).toEqual(false);
      });

      it('should return discussions for the given lineCode', () => {
        const { lineCode } = getDiffFileMock().highlightedDiffLines[1];
        const component = createComponent({ lineCode, showCommentButton: true });

        setDiscussions(component);

        expect(component.discussions).toEqual(getDiscussionsMockData());
        expect(component.hasDiscussions).toEqual(true);
        expect(component.shouldShowAvatarsOnGutter).toEqual(true);

        resetDiscussions(component);
      });
    });
  });

  describe('template', () => {
    it('should render three dots for context lines', () => {
      const component = createComponent({
        isMatchLine: true,
      });

      expect(component.$el.querySelector('span').classList.contains('context-cell')).toEqual(true);
      expect(component.$el.innerText).toEqual('...');
    });

    it('should render comment button', () => {
      const component = createComponent({
        showCommentButton: true,
      });
      Object.defineProperty(component, 'isLoggedIn', {
        get() {
          return true;
        },
      });

      expect(component.$el.querySelector('.js-add-diff-note-button')).toBeDefined();
    });

    it('should render line link', () => {
      const lineNumber = 42;
      const lineCode = `LC_${lineNumber}`;
      const component = createComponent({ lineNumber, lineCode });
      const link = component.$el.querySelector('a');

      expect(link.href.indexOf(`#${lineCode}`) > -1).toEqual(true);
      expect(link.dataset.linenumber).toEqual(lineNumber.toString());
    });

    it('should render user avatars', () => {
      const component = createComponent({
        showCommentButton: true,
        lineCode: getDiffFileMock().highlightedDiffLines[1].lineCode,
      });

      setDiscussions(component);
      expect(component.$el.querySelector('.diff-comment-avatar-holders')).toBeDefined();
      resetDiscussions(component);
    });
  });
});
