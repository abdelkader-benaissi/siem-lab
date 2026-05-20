# Contributing

This is a personal learning project, but contributions are welcome!

## How to contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Run validation before committing:
   ```bash
   make validate
   ```
4. Commit your changes (`git commit -m 'feat: description'`)
5. Push to the branch (`git push origin feature/improvement`)
6. Open a Pull Request

## Development Setup

```bash
# Clone and configure
git clone https://github.com/abdelkader-benaissi/siem-lab.git
cd siem-lab
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
cp terraform/backend.tfbackend.example terraform/backend.tfbackend

# Validate without deploying
make validate
```

## Code Style

- **Terraform**: Run `terraform fmt` before committing
- **Ansible**: Follow [Ansible best practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- **Shell scripts**: Use `shellcheck` when possible

## Security

- Never commit credentials, API keys, or project IDs
- Use `.example` files for templates
- Test with `git diff --cached` before pushing
