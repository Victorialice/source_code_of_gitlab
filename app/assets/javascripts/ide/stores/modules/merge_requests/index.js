import state from './state';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';

export default {
  namespaced: true,
  state: state(),
  actions,
  mutations,
  getters,
};
