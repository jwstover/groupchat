let ChatInput = {
  mounted() {
    const form = this.el.closest("form");

    form && form.addEventListener("submit", () => {
      // Clear the textarea after submission
      this.el.value = "";
    })

    this.el.addEventListener("input", () => {
      this.el.style.height = "auto"; // Reset the height
      this.el.style.height = this.el.scrollHeight + "px"; // Set it to the scroll height
    });

    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter") {
        if (e.shiftKey || e.ctrlKey) {
          // Allow newline
          return;
        }

        e.preventDefault(); // Prevent newline from being added
        if (form) {
          form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }));
          this.el.style.height = "auto"; // Reset the height
        }
      }
    });
  }
};

export default ChatInput;
