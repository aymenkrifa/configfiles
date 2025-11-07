alias vim=nvim
alias rmvenv="sudo rm -r .venv"
alias stop_containers='if [ -z "$(docker ps -q)" ]; then echo "No containers are active"; else echo "Stopping containers: $(docker ps --format "{{.Names}}" | tr "\n" " ")"; docker stop $(docker ps -q); fi'
alias connect_to_ssh="sshpass -p password ssh -t user@address zsh"

