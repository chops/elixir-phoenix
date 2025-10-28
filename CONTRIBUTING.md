# Contributing to Elixir Systems Mastery

Thank you for your interest in this project! This is a personal learning journey, but contributions, suggestions, and feedback are welcome.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/elixir-phoenix.git
   cd elixir-phoenix
   ```

3. **Install dependencies**
   ```bash
   make setup
   ```

4. **Run tests**
   ```bash
   make test
   ```

## Development Workflow

### Before You Start
- Check existing issues and PRs
- Open an issue to discuss significant changes
- Follow the phase structure outlined in `docs/roadmap.md`

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

3. **Run quality checks**
   ```bash
   make check    # Format check
   make credo    # Linting
   make dialyzer # Type checking
   make test     # Tests
   ```

4. **Commit your changes**
   ```bash
   git commit -m "feat: add feature description"
   ```

   Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `test:` Test additions/changes
   - `refactor:` Code refactoring
   - `chore:` Maintenance tasks

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Use a clear, descriptive title
   - Reference any related issues
   - Describe your changes and why they're needed

## Code Standards

### Elixir Style
- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Run `mix format` before committing
- Keep functions small and focused
- Prefer pattern matching over conditionals
- Use descriptive variable and function names

### Documentation
- Add `@moduledoc` to all modules
- Add `@doc` to all public functions
- Include examples in docstrings
- Update relevant docs in `docs/` when changing behavior

### Testing
- Write tests for all new functionality
- Aim for >80% coverage
- Use descriptive test names
- Follow Arrange-Act-Assert pattern

### Commits
- Write clear, concise commit messages
- One logical change per commit
- Reference issues: `fixes #123` or `relates to #456`

## Pull Request Checklist

Before submitting a PR, ensure:

- [ ] Code follows project style (`make check` passes)
- [ ] All tests pass (`make test` passes)
- [ ] New code has tests
- [ ] Documentation is updated
- [ ] Credo analysis passes (`make credo` passes)
- [ ] Dialyzer passes (`make dialyzer` passes)
- [ ] Commit messages follow conventions
- [ ] PR description clearly explains changes

## Areas for Contribution

### Labs Apps
- Implementing phase-specific labs apps
- Adding additional exercises
- Improving existing implementations

### Pulse Apps
- Building out the Pulse product incrementally
- Adding features across phases
- Integration improvements

### Documentation
- Improving phase reading notes
- Adding more examples
- Creating tutorials
- Fixing typos and clarity issues

### Tooling
- Improving CI/CD
- Adding automation
- Better developer experience

### Checklists & Templates
- Expanding design checklists
- Creating more templates
- Runbook improvements

## Questions or Problems?

- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas
- Check existing documentation first

## Code of Conduct

### Our Standards
- Be respectful and inclusive
- Welcome beginners and all skill levels
- Focus on constructive feedback
- Assume good intentions

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information
- Spam or off-topic discussions

## License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers this project.

## Recognition

All contributors will be acknowledged in the project README. Significant contributions may be highlighted in phase completion notes.

## Thank You!

Your contributions help make this learning journey better for everyone. Whether it's a typo fix, a new feature, or thoughtful feedback—thank you for taking the time to contribute!
