# Who accessing cluster resources?

- User (kube-apiserver)
    - Admin
    - Devs
- End Users
    - Auth by hosted app
- Service Account
    - Bots

# kube-apiserver user authentication configuration options:
## static password file (pass, user, id)
    ```
    user-details.csv
    pass1,user1,u0001
    pass2,user2,u0002
    ```
    ExecStart=... \\
    --basic-auth-file=user-detail.csv

### restart kube-apiserver!


- static token file
- certificates
- 3rd party identity services