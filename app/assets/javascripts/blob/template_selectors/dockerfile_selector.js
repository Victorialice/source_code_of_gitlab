import Api from '../../api';

import FileTemplateSelector from '../file_template_selector';

export default class DockerfileSelector extends FileTemplateSelector {
  constructor({ mediator }) {
    super(mediator);
    this.config = {
      key: 'dockerfile',
      name: 'Dockerfile',
      pattern: /(Dockerfile)/,
      endpoint: Api.dockerfileYml,
      dropdown: '.js-dockerfile-selector',
      wrapper: '.js-dockerfile-selector-wrap',
    };
  }

  initDropdown() {
    // maybe move to super class as well
    this.$dropdown.glDropdown({
      data: this.$dropdown.data('data'),
      filterable: true,
      selectable: true,
      toggleLabel: item => item.name,
      search: {
        fields: ['name'],
      },
      clicked: options => this.reportSelectionName(options),
      text: item => item.name,
    });
  }
}
