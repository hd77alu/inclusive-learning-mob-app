# Flutter Group2 Final Project

An Inclusive Mobile Learning and Skills Platform for
Persons with Disabilities in Rwanda.

## Project Structure

architecture and key folders:

```
lib/
├── main.dart              # Application entry point
├── firebase.dart          # Firebase configuration
├── bloc/                  # State management (BLoC pattern)
├── data/                  # Data layer
│   ├── models/           # Data models and entities
│   ├── services/         # API and Firebase services
│   └── utils/            # Helper functions and utilities
└── presentation/          # UI layer
    ├── screens/          # Application screens
    ├── themes/           # Theme configuration
    └── widgets/          # Reusable UI components
```

## Git Workflow Guidelines

### Before Starting Work

1. **Always sync with the main branch**
   ```bash
   git pull origin main
   ```
   This ensures you have the latest changes before starting your work.

2. **Create a new branch for each feature or bug fix**
   ```bash
   git checkout -b feature/your-feature-name
   ```
   or
   ```bash
   git checkout -b fix/bug-description
   ```

### Branch Naming Conventions

- **Features**: `feature/feature-name` (e.g., `feature/user-authentication`)
- **Bug Fixes**: `fix/bug-description` (e.g., `fix/login-error`)
- **Hotfixes**: `hotfix/issue-description` (e.g., `hotfix/crash-on-startup`)
- **Documentation**: `docs/description` (e.g., `docs/update-readme`)

### Commit Message Guidelines

Write clear and meaningful commit messages that describe what changes were made and why, One giant “final” commit isn't acceptable.

**Format:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring without changing functionality
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependency updates

**Examples:**
```bash
git commit -m "feat: implement user authentication with Firebase"
git commit -m "fix: resolve null pointer exception in profile screen"
git commit -m "docs: update README with project structure"
git commit -m "refactor: optimize data fetching in services layer"
```

### Pull Requests

1. **Create a Pull Request (PR)** on GitHub when your feature is complete
2. **PR Title**: Use the same format as commit messages
3. **PR Description**: Include:
   - What changes were made
   - Why these changes were necessary
   - How to test the changes
   - Screenshots (if UI changes)
   - Related issues (if applicable)
4. **Keep PRs focused**: One feature or fix per PR

### Merging

- Only merge when there are no merge conflicts

### Best Practices

1. **Commit often**: Make small, logical commits rather than large, complex ones
2. **Pull frequently**: Stay up-to-date with the main branch to avoid merge conflicts
3. **Never commit sensitive data**: API keys, passwords, or credentials should be in `.gitignore`
4. **Test before pushing**: Ensure your code runs without errors
5. **Write descriptive PR descriptions**: Help reviewers understand your changes
6. **Keep branches short-lived**: Merge or close branches within a few days
7. **Resolve conflicts promptly**: Address merge conflicts as soon as they arise

### Common Commands Reference

```bash
# Check current status
git status

# View commit history
git log --oneline

# Switch to main branch
git checkout main

# View all branches
git branch -a

# Delete local branch
git branch -d branch-name

# Discard local changes
git checkout -- filename

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Update current branch with main
git pull origin main
```