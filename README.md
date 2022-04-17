# Ansible
My Ansible container

## Aim
Have a container ready to use ansible. For example, to perform initial installation on Raspberry Pi's.

## Use
Create an `ansible` directory, containing your playbooks. It will be mounted as `/srv/ansible` by the `docker-compose.yml`.
* Place your ansible files into `/srv/ansible`
  > On the host, you should see :
  > ```bash
  > ansible
  > docker-compose.yml
  > Dockerfile
  > README.md
  > ```
* Create the image :
  ```bash
  sudo docker-compose up --build --no-start
  ```
* Use it :
  ```bash
  sudo docker-compose run --rm ansible5
  ```
> **Nota bene**</br>
> * You enter the container as an **unprivileged user**. However, you can become `root` by typing `sudo -i`
> * Ansible is not available *container-wide*, **but** only to that specific unprivileged user

## Links
* [Ansible documentation](https://docs.ansible.com/)
* [Ansible installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Ansible modules](https://docs.ansible.com/ansible/2.7/modules/list_of_all_modules.html)
