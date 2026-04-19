<template>
  <div class="input-container">
    <label v-if="label" class="input-label">{{ label }}</label>
    <input 
      :type="type" 
      v-model="inputValue" 
      class="input" 
      :placeholder="placeholder"
      :maxlength="maxlength"
      @input="handleInput"
      @blur="handleBlur"
      @focus="handleFocus"
    >
  </div>
</template>

<script>
export default {
  props: {
    type: {
      type: String,
      default: 'text'
    },
    label: {
      type: String,
      default: ''
    },
    placeholder: {
      type: String,
      default: ''
    },
    maxlength: {
      type: Number,
      default: 0
    },
    value: {
      type: [String, Number],
      default: ''
    }
  },
  data() {
    return {
      inputValue: this.value
    }
  },
  watch: {
    value: {
      handler(newValue) {
        this.inputValue = newValue
      },
      immediate: true
    },
    inputValue(newValue) {
      this.$emit('input', newValue)
    }
  },
  methods: {
    handleInput(event) {
      this.$emit('input', event.target.value)
    },
    handleBlur(event) {
      this.$emit('blur', event)
    },
    handleFocus(event) {
      this.$emit('focus', event)
    }
  }
}
</script>

<style scoped>
.input-container {
  margin-bottom: 15px;
}

.input-label {
  display: block;
  font-size: 14px;
  color: #666;
  margin-bottom: 5px;
}

.input {
  width: 100%;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  outline: none;
  transition: border-color 0.3s;
}

.input:focus {
  border-color: #ff6b6b;
}
</style>