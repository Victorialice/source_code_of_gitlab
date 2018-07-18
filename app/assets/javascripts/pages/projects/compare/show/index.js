import Diff from '~/diff';
import initChangesDropdown from '~/init_changes_dropdown';
import GpgBadges from '~/gpg_badges';

document.addEventListener('DOMContentLoaded', () => {
  new Diff(); // eslint-disable-line no-new
  const paddingTop = 16;
  initChangesDropdown(document.querySelector('.navbar-gitlab').offsetHeight - paddingTop);
  GpgBadges.fetch();
});
