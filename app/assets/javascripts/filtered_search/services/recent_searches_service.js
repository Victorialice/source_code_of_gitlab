import RecentSearchesServiceError from './recent_searches_service_error';
import AccessorUtilities from '../../lib/utils/accessor';

class RecentSearchesService {
  constructor(localStorageKey = 'issuable-recent-searches') {
    this.localStorageKey = localStorageKey;
  }

  fetch() {
    if (!RecentSearchesService.isAvailable()) {
      const error = new RecentSearchesServiceError();
      return Promise.reject(error);
    }

    const input = window.localStorage.getItem(this.localStorageKey);

    let searches = [];
    if (input && input.length > 0) {
      try {
        searches = JSON.parse(input);
      } catch (err) {
        return Promise.reject(err);
      }
    }

    return Promise.resolve(searches);
  }

  save(searches = []) {
    if (!RecentSearchesService.isAvailable()) return;

    window.localStorage.setItem(this.localStorageKey, JSON.stringify(searches));
  }

  static isAvailable() {
    return AccessorUtilities.isLocalStorageAccessSafe();
  }
}

export default RecentSearchesService;
