import os

# Конфигурация агентов (навыков)
AGENTS = {
    "dev_agent": {
        "title": "Development Agent",
        "desc": "Code implementation, refactoring, and logic fixes.",
        "content": """## 1. Think Before Coding
- State assumptions.
- Push back on complexity.
- Ask if unclear.

## 2. Simplicity First
- Minimum code to solve the problem.
- No over-engineering.

## 3. Surgical Changes
- Touch only what is necessary.
- Match existing style.

## 4. Goal-Driven Execution
- Define success criteria.
- Verify after every step.
"""
    },
    "wiki_agent": {
        "title": "Wiki Agent",
        "desc": "Knowledge management and project documentation.",
        "content": """## 1. Documentation First
- Update Wiki before and after code changes.
- Maintain index.md and navigation.

## 2. Logging
- Record every major action in log.md.
- Format: [YYYY-MM-DD] | [File] | [Action].

## 3. Bug Tracking
- Log bugs in BUGS.md immediately upon discovery.
"""
    },
    "qa_agent": {
        "title": "QA Agent",
        "desc": "Bug hunting and quality assurance.",
        "content": """## 1. Hunting
- Perform static analysis.
- Run automated tests (pytest).

## 2. Reporting
- Document bugs with reproduction steps.
- Verify fixes before closing.
"""
    },
    "build_agent": {
        "title": "Build Agent",
        "desc": "Packaging and distribution.",
        "content": """## 1. Preparation
- Clean build directories.
- Check dependencies.

## 2. Bundling
- Use PyInstaller/PyArmor as configured.
- Verify the final executable.
"""
    },
    "release_agent": {
        "title": "Release Agent",
        "desc": "Changelog and release notes generation.",
        "content": """## 1. Synthesis
- Summarize changes from log.md.
- Categorize: Features, Fixes, UX.

## 2. Formatting
- Create Changelog_vX.X.X.txt.
"""
    },
    "product_agent": {
        "title": "Product Agent",
        "desc": "Strategic planning and ideation.",
        "content": """## 1. Analysis
- Audit project progress.
- Suggest next steps for the Roadmap.

## 2. Innovation
- Research trends and user needs.
"""
    },
    "security_agent": {
        "title": "Security Agent",
        "desc": "Privacy and integrity audit.",
        "content": """## 1. Audit
- Check for sensitive data leaks.
- Verify code obfuscation.
"""
    },
    "support_agent": {
        "title": "Support Agent",
        "desc": "User manuals and in-app help.",
        "content": """## 1. Documentation
- Keep User_Manual.md in sync with features.
- Improve in-app tooltips and labels.
"""
    },
    "performance_agent": {
        "title": "Performance Agent",
        "desc": "Optimization and resource management.",
        "content": """## 1. Profiling
- Identify slow code and memory leaks.
- Optimize core loops.
"""
    }
}

# Конфигурация Wiki
WIKI_FILES = {
    "index.md": "# 📘 Project Wiki Index\\n\\nWelcome to the knowledge base.\\n\\n- [[ROADMAP]]\\n- [[CHECKLIST]]\\n- [[log]]",
    "log.md": "# 📂 Activity Log\\n\\n## [YYYY-MM-DD HH:mm] | [Project] | [INIT] | Project initialized with Agentic Skillset.",
    "CHECKLIST.md": "# ✅ Operational Checklist\\n\\n- [ ] Initialize project structure",
    "ROADMAP.md": "# 🗺 Strategic Roadmap\\n\\n- **Phase 1**: Initial setup"
}

# Конфигурация мастер-правил (Gemini.md)
GEMINI_CONTENT = """# 🤖 Agentic Workflow Rules

This project is built using an agent-based architecture. ALL interactions and development MUST follow the guidelines stored in the `.agents` directory.

## 🚩 Core Mandates

1. **Agent Dominance**: Before starting any task, consult the relevant skill in `.agents/skills/`.
2. **Wiki First**: Every change must be reflected in the project Wiki (`/wiki`) using the `wiki_agent` protocols.
3. **Logging**: All major actions must be recorded in `wiki/log.md` formatted as `[YYYY-MM-DD] | [File] | [Action]`.
4. **Bug Tracking**: Any issues discovered during development must be logged in `wiki/BUGS.md` immediately.

## 🛠️ Specialized Agents

- **Wiki Agent**: Documentation, knowledge management, and archives.
- **Dev Agent**: Core logic, refactoring, and code standards.
- **QA Agent**: Systematic bug hunting and quality assurance.
- **Product Agent**: Strategy, ideation, and roadmap evolution.
- **Build Agent**: Obfuscation and bundling for production.
- **Release Agent**: Generation of professional changelogs.
- **Security Agent**: Privacy audit and software integrity.
- **Support Agent**: User manuals and in-app help systems.
- **Performance Agent**: Latency optimization and resource management.

---
**STRICT ADHERENCE TO THESE RULES IS MANDATORY.**
"""

def init_project():
    print("🚀 Initializing Agentic Project Structure...")

    # Создание структуры папок
    dirs = [
        ".agents/skills",
        "wiki",
        "raw-sources",
        "src",
        "tests"
    ]

    for d in dirs:
        os.makedirs(d, exist_ok=True)
        print(f"Created directory: {d}")

    # Создание агентов
    for name, data in AGENTS.items():
        agent_dir = f".agents/skills/{name}"
        os.makedirs(agent_dir, exist_ok=True)
        
        skill_path = os.path.join(agent_dir, "SKILL.md")
        with open(skill_path, "w", encoding="utf-8") as f:
            f.write(f"---\\ntitle: {data['title']}\\ndescription: {data['desc']}\\n---\\n\\n# 🤖 Skill: {data['title']}\\n\\n{data['content']}")
        print(f"Created Agent: {name}")

    # Создание файлов Wiki
    for filename, content in WIKI_FILES.items():
        wiki_path = os.path.join("wiki", filename)
        with open(wiki_path, "w", encoding="utf-8") as f:
            f.write(content.replace("\\n", "\\n"))
        print(f"Created Wiki file: {filename}")

    # Создание Gemini.md (Master Rules)
    if not os.path.exists("Gemini.md"):
        with open("Gemini.md", "w", encoding="utf-8") as f:
            f.write(GEMINI_CONTENT)
        print("Created Master Rules: Gemini.md")

    # Создание базовых файлов проекта
    if not os.path.exists("main.py"):
        with open("main.py", "w", encoding="utf-8") as f:
            f.write("print('Hello from Agentic Project!')\\n")
    
    if not os.path.exists("requirements.txt"):
        with open("requirements.txt", "w", encoding="utf-8") as f:
            f.write("# Project dependencies\\n")

    print("\\n✨ Project initialized successfully!")
    print("Happy coding with your AI team!")

if __name__ == "__main__":
    init_project()
