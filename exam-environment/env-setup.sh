sudo -i
# autocompletion
# you will get it from here: https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
alias k=kubectl
complete -F __start_kubectl k

# env variables
export do="--dry-run=client -o yaml"
export now="--grace-period=0 --force"

# aliases
alias current-ns="k config view --minify | grep namespace"
alias change-ns="k config set-context --current --namespace" # that was really useful! I didn't use -n switch.
alias kex="k explain --recursive"
# vim setup
vim .vimrc
set nu ruler expandtab ts=2 sw=2
source .vimrc


export ns=default
alias k='kubectl -n $ns' # This helps when namespace in question doesn't have a friendly name 
alias kdr= 'kubectl -n $ns -o yaml --dry-run'.  # run commands in dry run mode and generate yaml.
