<script>
import { mapActions } from 'vuex';
import icon from '~/vue_shared/components/icon.vue';
import newModal from './modal.vue';
import upload from './upload.vue';
import ItemButton from './button.vue';

export default {
  components: {
    icon,
    newModal,
    upload,
    ItemButton,
  },
  props: {
    branch: {
      type: String,
      required: true,
    },
    path: {
      type: String,
      required: false,
      default: '',
    },
    mouseOver: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      dropdownOpen: false,
    };
  },
  watch: {
    dropdownOpen() {
      this.$nextTick(() => {
        this.$refs.dropdownMenu.scrollIntoView();
      });
    },
    mouseOver() {
      if (!this.mouseOver) {
        this.dropdownOpen = false;
      }
    },
  },
  methods: {
    ...mapActions(['createTempEntry', 'openNewEntryModal']),
    createNewItem(type) {
      this.openNewEntryModal({ type, path: this.path });
      this.dropdownOpen = false;
    },
    openDropdown() {
      this.dropdownOpen = !this.dropdownOpen;
    },
  },
};
</script>

<template>
  <div class="ide-new-btn">
    <div
      :class="{
        show: dropdownOpen,
      }"
      class="dropdown d-flex"
    >
      <button
        :aria-label="__('Create new file or directory')"
        type="button"
        class="rounded border-0 d-flex ide-entry-dropdown-toggle"
        @click.stop="openDropdown()"
      >
        <icon
          name="hamburger"
        />
        <icon
          name="arrow-down"
        />
      </button>
      <ul
        ref="dropdownMenu"
        class="dropdown-menu dropdown-menu-right"
      >
        <li>
          <item-button
            :label="__('New file')"
            class="d-flex"
            icon="doc-new"
            icon-classes="mr-2"
            @click="createNewItem('blob')"
          />
        </li>
        <li>
          <upload
            :path="path"
            @create="createTempEntry"
          />
        </li>
        <li>
          <item-button
            :label="__('New directory')"
            class="d-flex"
            icon="folder-new"
            icon-classes="mr-2"
            @click="createNewItem('tree')"
          />
        </li>
      </ul>
    </div>
  </div>
</template>
