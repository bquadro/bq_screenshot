<template>
  <section class="image-editor-page d-flex flex-column">
    <header class="d-flex align-items-center justify-content-between px-4 py-3 border-bottom">
      <div>
        <h2 class="h5 mb-1">{{ title }}</h2>
        <p class="small text-muted mb-0">{{ description }}</p>
      </div>
      <div class="d-flex gap-2">
        <button class="btn btn-outline-secondary" type="button" @click="handleCancel">
          {{ cancelLabel }}
        </button>
        <button class="btn btn-primary" type="button" @click="handleSave">
          {{ saveLabel }}
        </button>
      </div>
    </header>
    <div
      class="editor-wrapper flex-fill"
      ref="editorContainer"
      :style="{ height: `${editorWrapperHeight}px` }"
    ></div>
  </section>
</template>

<script setup>
import { defineProps, defineEmits, ref, onMounted, onBeforeUnmount, watch, nextTick } from 'vue';
import ImageEditor from 'tui-image-editor';
import 'tui-image-editor/dist/tui-image-editor.css';
import 'tui-color-picker/dist/tui-color-picker.css';

const props = defineProps({
  imageData: {
    type: String,
    required: true,
  },
  title: {
    type: String,
    default: 'Image editor',
  },
  description: {
    type: String,
    default: '',
  },
  saveLabel: {
    type: String,
    default: 'Save',
  },
  cancelLabel: {
    type: String,
    default: 'Cancel',
  },
});

const emit = defineEmits(['save', 'cancel']);
const editorContainer = ref(null);
let editorInstance = null;
const editorWrapperHeight = ref(400);

const mountEditor = () => {
  if (!editorContainer.value) {
    return;
  }

  if (editorInstance) {
    editorInstance.destroy();
    editorInstance = null;
  }

  editorInstance = new ImageEditor(editorContainer.value, {
    includeUI: {
      loadImage: {
        path: props.imageData,
        name: 'Screenshot',
      },
      menu: ['crop', 'draw', 'shape', 'text', 'flip', 'filter'],
      initMenu: 'draw',
      menuBarPosition: 'bottom',
      uiSize: {
        width: '100%',
        height: '100%',
      },
    },
    cssMaxWidth: 1000,
    cssMaxHeight: 600,
    selectionStyle: {
      cornerSize: 20,
      rotatingPointOffset: 70,
    },
    usageStatistics: false,
  });

  if (props.imageData) {
    editorInstance.loadImageFromURL(props.imageData, 'Screenshot').then(() => {
      editorInstance.clearUndoStack();
      updateWrapperHeight();
    });
  }
};

const reloadImage = () => {
  if (editorInstance && props.imageData) {
    editorInstance.loadImageFromURL(props.imageData, 'Screenshot').then(() => {
      editorInstance.clearUndoStack();
      updateWrapperHeight();
    });
  }
};

const updateWrapperHeight = () => {
  if (!editorInstance) {
    return;
  }
  const canvasSize = editorInstance.getCanvasSize();
  if (!canvasSize?.height) {
    return;
  }
  const maxAllowed = window.innerHeight - 140;
  const desiredHeight = Math.min(Math.max(canvasSize.height, 400), maxAllowed);
  editorWrapperHeight.value = desiredHeight;
  if (editorInstance.ui?.resizeEditor) {
    editorInstance.ui.resizeEditor({
      uiSize: {
        width: '100%',
        height: desiredHeight,
      },
    });
  }
};

watch(
  () => props.imageData,
  () => {
    nextTick(() => {
      if (editorInstance) {
        reloadImage();
      } else {
        mountEditor();
      }
    });
  },
);

onMounted(() => {
  mountEditor();
  window.addEventListener('resize', updateWrapperHeight);
});

onBeforeUnmount(() => {
  if (editorInstance) {
    editorInstance.destroy();
    editorInstance = null;
  }
  window.removeEventListener('resize', updateWrapperHeight);
});

const handleSave = () => {
  if (!editorInstance) {
    return;
  }

  const dataUrl = editorInstance.toDataURL();
  emit('save', dataUrl);
};

const handleCancel = () => {
  emit('cancel');
};
</script>

<style scoped>
.image-editor-page {
  min-height: 0;
  flex: 1;
  background: #f8f9fa;
}

.editor-wrapper {
  flex: 1;
  position: relative;
}

:global(.tui-image-editor-wrapper) {
  height: 100%;
}

:global(.tui-image-editor-header-buttons .tui-image-editor-load-btn),
:global(.tui-image-editor-header-buttons .tui-image-editor-download-btn) {
  display: none !important;
}

:global(.tui-image-editor) {
  height: 100%;
}
</style>
