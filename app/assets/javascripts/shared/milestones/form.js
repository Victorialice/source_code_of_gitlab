import $ from 'jquery';
import ZenMode from '../../zen_mode';
import DueDateSelectors from '../../due_date_select';
import GLForm from '../../gl_form';

export default (initGFM = true) => {
  new ZenMode(); // eslint-disable-line no-new
  new DueDateSelectors(); // eslint-disable-line no-new
  // eslint-disable-next-line no-new
  new GLForm($('.milestone-form'), {
    emojis: true,
    members: initGFM,
    issues: initGFM,
    mergeRequests: initGFM,
    epics: initGFM,
    milestones: initGFM,
    labels: initGFM,
  });
};
