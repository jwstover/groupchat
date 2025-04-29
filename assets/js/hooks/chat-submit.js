let ChatInput = {
  mounted() {
    const form = this.el.closest("form");

    form && form.addEventListener("submit", (e) => {
      e.preventDefault();
      e.stopPropagation();

      const message = this.el.value; // Capture the message
      if (message.trim() !== "") {
        this.pushEvent("send", { message: message }); // Send the message to the server
        form.reset(); // Clear the form after sending
        console.log("Message sent and form cleared");
      }
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
