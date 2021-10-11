### Deploy Supertux2
**1)Pre-configuration**

*First of all write 2 env. variables that starts with TF_VAR to your rc file ($HOME/.bashrc or $HOME/.zshrc)*
```bash
export AWS_ACCESS_KEY_ID=WRITE_YOUR_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=WRITE_YOUR_AWS_SECRET_ACCESS_KEY
```

**2)git clone repo**
```bash
git clone https://github.com/avorr/supertux-infra.git
```

**3)install terraform and run `terraform init` in repo**
```bash
terraform init
```
**4)run script  `apply.sh`**
```bash
./apply.sh
```
