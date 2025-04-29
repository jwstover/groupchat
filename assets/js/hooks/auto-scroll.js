let AutoScroll = {
  mounted() {
    setTimeout(() => this.scrollToBottom(), 200);
  },
  updated() {
    setTimeout(() => this.scrollToBottom(), 200);
  },
  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight
  }
}

export default AutoScroll;
