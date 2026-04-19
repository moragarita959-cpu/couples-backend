<template>
  <button class="btn" :class="[type, size, { disabled }]" @click="handleClick" :disabled="disabled">
    <slot></slot>
  </button>
</template>

<script>
export default {
  props: {
    type: {
      type: String,
      default: 'primary',
      validator: (value) => ['primary', 'secondary', 'danger'].includes(value)
    },
    size: {
      type: String,
      default: 'medium',
      validator: (value) => ['small', 'medium', 'large'].includes(value)
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    handleClick() {
      if (!this.disabled) {
        this.$emit('click')
      }
    }
  }
}
</script>

<style scoped>
.btn {
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.3s;
}

.btn.primary {
  background-color: #ff6b6b;
  color: white;
}

.btn.primary:hover {
  background-color: #ff5252;
}

.btn.secondary {
  background-color: #f0f0f0;
  color: #333;
}

.btn.secondary:hover {
  background-color: #e0e0e0;
}

.btn.danger {
  background-color: #ff4757;
  color: white;
}

.btn.danger:hover {
  background-color: #ff3742;
}

.btn.small {
  padding: 8px 16px;
  font-size: 14px;
}

.btn.medium {
  padding: 12px 24px;
  font-size: 16px;
}

.btn.large {
  padding: 16px 32px;
  font-size: 18px;
}

.btn.disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.btn.disabled:hover {
  background-color: #ccc;
}
</style>