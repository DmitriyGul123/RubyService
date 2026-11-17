import "@hotwired/turbo-rails"

document.addEventListener("click", async (event) => {
  const target = event.target
  if (!(target instanceof Element)) return

  const copyButton = target.closest("[data-share-copy]")
  if (copyButton) {
    const menu = copyButton.closest(".share-menu")
    const urlField = menu.querySelector("[data-share-url]")
    const status = menu.querySelector(".share-status")

    try {
      await navigator.clipboard.writeText(urlField.value)
      status.textContent = "Ссылка скопирована."
    } catch {
      urlField.focus()
      urlField.select()
      status.textContent = "Не удалось скопировать автоматически. Ссылка выделена для копирования."
    }

    return
  }

  document.querySelectorAll(".share-menu[open]").forEach((menu) => {
    if (!menu.contains(target)) menu.open = false
  })
})

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return

  const menu = document.querySelector(".share-menu[open]")
  if (!menu) return

  menu.open = false
  menu.querySelector("summary").focus()
})