const { Modal, Notice, Plugin, Setting, moment, normalizePath } = require("obsidian");

const EXPERIMENT_FOLDER = "knowledge-base/Experiments";
const EXPERIMENT_TEMPLATE = "Templates/Experiment.md";

class ExperimentNameModal extends Modal {
  constructor(app, onSubmit) {
    super(app);
    this.onSubmit = onSubmit;
  }

  onOpen() {
    const { contentEl } = this;
    contentEl.empty();
    contentEl.createEl("h2", { text: "New experiment" });

    let name = "";
    let category = "architecture";
    const submit = () => {
      const cleanName = name.trim();
      if (!cleanName) return;
      this.close();
      void this.onSubmit(cleanName, category);
    };

    new Setting(contentEl).setName("Name").addText((text) => {
      text.setPlaceholder("e.g. MTP coefficient sweep");
      text.onChange((value) => {
        name = value;
      });
      text.inputEl.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
          event.preventDefault();
          submit();
        }
      });
      window.setTimeout(() => text.inputEl.focus(), 0);
    });

    new Setting(contentEl).setName("Category").addDropdown((dropdown) => {
      dropdown
        .addOption("architecture", "Architecture")
        .addOption("data", "Data")
        .addOption("scaling", "Scaling")
        .addOption("systems", "Systems")
        .setValue(category)
        .onChange((value) => {
          category = value;
        });
    });

    new Setting(contentEl).addButton((button) => {
      button.setButtonText("Create").setCta().onClick(submit);
    });
  }

  onClose() {
    this.contentEl.empty();
  }
}

class FreeformNameModal extends Modal {
  constructor(app, onSubmit) { super(app); this.onSubmit = onSubmit; }
  onOpen() {
    this.contentEl.createEl("h2", { text: "New experiment" });
    this.contentEl.createEl("p", { text: "Give it a name, then write freely. Add #tags anywhere as you go." });
    let name = "";
    const submit = () => { this.close(); void this.onSubmit(name); };
    new Setting(this.contentEl).setName("Name").addText((text) => {
      text.setPlaceholder("Optional — defaults to the current date and time");
      text.onChange((value) => { name = value; });
      text.inputEl.addEventListener("keydown", (event) => {
        if (event.key === "Enter") { event.preventDefault(); submit(); }
      });
      window.setTimeout(() => text.inputEl.focus(), 0);
    });
    new Setting(this.contentEl).addButton((button) => button.setButtonText("Start writing").setCta().onClick(submit));
  }
  onClose() { this.contentEl.empty(); }
}

module.exports = class LagunaWorkflowPlugin extends Plugin {
  async onload() {
    // Return state is ephemeral: never persist private note paths.
    this.returnState = null;
    this.returnCursor = null;
    this.addRibbonIcon("flask-conical", "New experiment", () => this.openFreeformModal());
    this.addCommand({ id: "new-experiment", name: "New experiment", callback: () => this.openFreeformModal() });
    this.addCommand({ id: "new-structured-experiment", name: "New structured experiment (optional)", callback: () => this.openExperimentModal() });
    this.addCommand({ id: "toggle-graph", name: "Toggle graph", callback: () => this.toggleGraph() });
  }

  openFreeformModal() {
    new FreeformNameModal(this.app, (name) => this.createFreeformExperiment(name)).open();
  }

  async createFreeformExperiment(name) {
    const safeName = name.replace(/[\\/:*?"<>|]/g, "-").replace(/\s+/g, " ").trim();
    const title = safeName || `Experiment ${moment().format("YYYY-MM-DD HHmmss")}`;
    await this.ensureFolder("inbox");
    let path = normalizePath(`inbox/${title}.md`);
    for (let suffix = 2; this.app.vault.getAbstractFileByPath(path); suffix++) {
      path = normalizePath(`inbox/${title} ${suffix}.md`);
    }
    const file = await this.app.vault.create(path, `Date: ${moment().format("YYYY-MM-DD")}\n\n#experiment\n\n`);
    const leaf = this.app.workspace.getLeaf(false);
    await leaf.openFile(file, { state: { mode: "source", source: false } });
    leaf.view.editor?.setCursor({ line: 4, ch: 0 });
    leaf.view.editor?.focus();
  }

  openExperimentModal() {
    new ExperimentNameModal(this.app, (name, category) => this.createExperiment(name, category)).open();
  }

  async ensureFolder(path) {
    const parts = normalizePath(path).split("/");
    let current = "";
    for (const part of parts) {
      current = current ? `${current}/${part}` : part;
      if (!this.app.vault.getAbstractFileByPath(current)) {
        await this.app.vault.createFolder(current);
      }
    }
  }

  async readTemplate(path) {
    const templateFile = this.app.vault.getAbstractFileByPath(path);
    if (!templateFile) {
      new Notice(`Template not found: ${path}`);
      return null;
    }
    return this.app.vault.read(templateFile);
  }

  async createExperiment(name, category = "architecture") {
    const safeName = name.replace(/[\\/:*?"<>|]/g, "-").replace(/\s+/g, " ").trim();
    const path = normalizePath(`${EXPERIMENT_FOLDER}/${safeName}.md`);

    if (this.app.vault.getAbstractFileByPath(path)) {
      new Notice(`Experiment already exists: ${safeName}`);
      return;
    }

    await this.ensureFolder(EXPERIMENT_FOLDER);
    const date = moment().format("MM-DD");
    const template = await this.readTemplate(EXPERIMENT_TEMPLATE);
    if (!template) return;
    const content = template
      .replaceAll("{{date:MM-DD}}", date)
      .replace(/^category: architecture$/m, `category: ${category}`)
      .replace(/`architecture`/m, `\`${category}\``)
      .replace(/^# Experiment name$/m, `# ${safeName}`);

    const file = await this.app.vault.create(path, content);
    await this.app.workspace.getLeaf(false).openFile(file);
  }

  async toggleGraph() {
    const workspace = this.app.workspace;
    const leaf = workspace.getMostRecentLeaf?.() || workspace.activeLeaf;
    if (!leaf) return;
    if (leaf.view?.getViewType() === "graph") {
      if (this.returnState) {
        const state = this.returnState;
        const cursor = this.returnCursor;
        this.returnState = null;
        this.returnCursor = null;
        await leaf.setViewState(state);
        workspace.setActiveLeaf(leaf, { focus: true });
        if (cursor) leaf.view.editor?.setCursor(cursor);
        leaf.view.editor?.focus();
      } else {
        this.app.commands.executeCommandById("app:go-back");
      }
      return;
    }
    this.returnState = JSON.parse(JSON.stringify(leaf.getViewState()));
    this.returnCursor = leaf.view.editor?.getCursor() ?? null;
    await leaf.setViewState({ type: "graph", state: { type: "global" } });
    workspace.setActiveLeaf(leaf, { focus: true });
  }
};
