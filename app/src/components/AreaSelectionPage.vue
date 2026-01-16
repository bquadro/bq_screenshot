<template>
  <section class="area-selection-page d-flex flex-column">
    <header class="d-flex align-items-center justify-content-between px-4 py-3 border-bottom">
      <div>
        <h2 class="h5 mb-1">{{ title }}</h2>
        <p class="small text-muted mb-0">{{ description }}</p>
      </div>
      <div class="d-flex gap-2">
        <button class="btn btn-outline-secondary" type="button" @click="handleCancel">
          {{ cancelLabel }}
        </button>
        <button class="btn btn-primary" type="button" :disabled="!selection" @click="handleSave">
          {{ saveLabel }}
        </button>
      </div>
    </header>

    <div class="area-wrapper flex-grow-1" ref="wrapper" @mousedown="startSelection" @mousemove="updateSelection" @mouseup="endSelection" @mouseleave="cancelSelection">
      <img ref="imageRef" :src="imageData" alt="Скриншот" draggable="false" />
      <div v-if="selection" class="selection-rect" :style="selectionStyle"></div>
      <p class="instructions">{{ instructions }}</p>
    </div>
  </section>
</template>

<script setup>
import { defineProps, defineEmits, ref, computed, watch } from 'vue';

const props = defineProps({
  imageData: {
    type: String,
    required: true,
  },
  title: {
    type: String,
    default: 'Выбор области',
  },
  description: {
    type: String,
    default: '',
  },
  instructions: {
    type: String,
    default: 'Выделите область для сохранения.',
  },
  saveLabel: {
    type: String,
    default: 'Далее',
  },
  cancelLabel: {
    type: String,
    default: 'Отмена',
  },
});

const emit = defineEmits(['crop', 'cancel']);
const wrapper = ref(null);
const imageRef = ref(null);
const startX = ref(0);
const startY = ref(0);
const selection = ref(null);
const isDrawing = ref(false);

const selectionStyle = computed(() => {
  if (!selection.value) {
    return {};
  }
  return {
    left: `${selection.value.x}px`,
    top: `${selection.value.y}px`,
    width: `${selection.value.width}px`,
    height: `${selection.value.height}px`,
  };
});

const startSelection = (event) => {
  if (!wrapper.value) return;
  isDrawing.value = true;
  const rect = wrapper.value.getBoundingClientRect();
  startX.value = event.clientX - rect.left;
  startY.value = event.clientY - rect.top;
  selection.value = { x: startX.value, y: startY.value, width: 0, height: 0 };
};

const updateSelection = (event) => {
  if (!isDrawing.value || !wrapper.value) return;
  const rect = wrapper.value.getBoundingClientRect();
  const x = event.clientX - rect.left;
  const y = event.clientY - rect.top;
  const width = Math.abs(x - startX.value);
  const height = Math.abs(y - startY.value);
  const left = Math.min(x, startX.value);
  const top = Math.min(y, startY.value);
  selection.value = { x: Math.max(0, left), y: Math.max(0, top), width: Math.max(0, width), height: Math.max(0, height) };
};

const endSelection = () => {
  isDrawing.value = false;
};

const cancelSelection = () => {
  if (!isDrawing.value) return;
  isDrawing.value = false;
};

watch(
  () => props.imageData,
  () => {
    selection.value = null;
  },
);

const handleSave = () => {
  if (!selection.value || !imageRef.value) {
    return;
  }

  const image = imageRef.value;
  const scaleX = image.naturalWidth / image.clientWidth;
  const scaleY = image.naturalHeight / image.clientHeight;
  const cropX = Math.round(selection.value.x * scaleX);
  const cropY = Math.round(selection.value.y * scaleY);
  const cropWidth = Math.round(selection.value.width * scaleX);
  const cropHeight = Math.round(selection.value.height * scaleY);

  const canvas = document.createElement('canvas');
  canvas.width = cropWidth;
  canvas.height = cropHeight;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(image, cropX, cropY, cropWidth, cropHeight, 0, 0, cropWidth, cropHeight);
  emit('crop', canvas.toDataURL('image/png'));
};

const handleCancel = () => {
  emit('cancel');
};
</script>

<style scoped>
.area-selection-page {
  min-height: 0;
  flex: 1;
  background: #f8f9fa;
}

.area-wrapper {
  position: relative;
  flex: 1;
  overflow: hidden;
  background: #000;
}

.area-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
  user-select: none;
}

.selection-rect {
  position: absolute;
  border: 2px dashed #00aeff;
  background: rgba(0, 174, 255, 0.2);
  pointer-events: none;
}

.instructions {
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  margin: 0 0 12px;
  padding: 6px 12px;
  background: rgba(0, 0, 0, 0.6);
  color: #fff;
  border-radius: 4px;
  font-size: 0.8rem;
  pointer-events: none;
}
</style>
