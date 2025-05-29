# Jenkins Build and Deploy – React Application on EC2

This guide explains how to set up a Jenkins pipeline to **automatically build and deploy a React application** whenever code is pushed to a GitHub repository.

We will:

- Set up Jenkins on an AWS EC2 server.
- Configure SSH between Jenkins and a build server.
- Create a Jenkins pipeline that uses `build.sh` and `deploy.sh`.
- Trigger deployments on every GitHub push via webhook.

---

## 🧰 Prerequisites

- Two AWS EC2 Ubuntu instances:
  - **Jenkins Server**
  - **Deploy Server (Build and Deployment target)**
- React app repository with `build.sh` and `deploy.sh` scripts.
- GitHub repository (public or authenticated).

---

## 🔧 Step-by-Step Setup

### 1. Install Java on Jenkins Server

```bash
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
````

---

### 2. Install Jenkins

```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins
```

---

### 3. Start Jenkins

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

> Jenkins runs on **port 8080**. Add port 8080 to EC2 security group inbound rules.

Access Jenkins at: `http://<AWS_PUBLIC_IP>:8080`

---

### 4. Unlock Jenkins

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

* Paste the password on the Jenkins web UI.
* Install suggested plugins.
* Create your admin user.

---

### 5. Connect Agent server to Deploy server Server (SSH)

```bash
ssh-keygen
```

* Copy the contents of `/home/ubuntu/.ssh/id_rsa.pub`
* Paste into `/home/ubuntu/.ssh/authorized_keys` on the Demo Server.

Test connection:

```bash
ssh ubuntu@<DeployServer_Private_IP>
exit
```

---

### 6. Install Java on Agent (Demo Server)

```bash
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
```

---

### 7. Configure Jenkins Agent (Slave)

```bash
curl -sO http://<JENKINS_PUBLIC_IP>:8080/jnlpJars/agent.jar

java -jar agent.jar -url http://<JENKINS_PUBLIC_IP>:8080/ \
  -secret <YOUR_SECRET> -name slave -webSocket -workDir "/opt/build/"
```

---

## 🛠 Jenkinsfile for React App Build & Deploy

Place this in your **React app repo** root:

```groovy
pipeline {
    agent { label 'slave' } // Replace 'slave' with your actual node label

    environment {
        AWS_PRIVATE_IP = '172.31.30.63' // Define the private IP address here
    }

    stages {
        stage('Clean up and clone') {
            steps {
                script {
                    sh """
                        ssh ubuntu@${AWS_PRIVATE_IP} 'rm -rf /home/ubuntu/Udemy-section*'
                        ssh ubuntu@${AWS_PRIVATE_IP} 'git clone https://github.com/sagarkakkalasworld/Udemy-section4.git'
                    """
                }
            }
        }

        stage('Set Script Permissions') {
            steps {
                script {
                    sh """
                        ssh ubuntu@${AWS_PRIVATE_IP} 'chmod 744 /home/ubuntu/Udemy-section4/build.sh'
                        ssh ubuntu@${AWS_PRIVATE_IP} 'chmod 744 /home/ubuntu/Udemy-section4/deploy.sh'
                    """
                }
            }
        }

        stage('Build React code') {
            steps {
                script {
                    sh "ssh ubuntu@${AWS_PRIVATE_IP} '/home/ubuntu/Udemy-section4-code/build.sh'"
                }
            }
        }

        stage('Deploy in nginx') {
            steps {
                script {
                    sh "ssh ubuntu@${AWS_PRIVATE_IP} '/home/ubuntu/Udemy-section4-code/deploy.sh'"
                }
            }
        }
    }
}

```

---

## 🚀 Create Pipeline in Jenkins

1. Jenkins → New Item → Enter name → Select **"Pipeline"**
2. Check **GitHub hook trigger for Git SCM polling**
3. Under "Pipeline from SCM":

   * Choose Git
   * Enter GitHub repo URL
   * Leave credentials as "None" (for public repos)
   * Branch: `main`
   * Script Path: `Jenkinsfile`
4. Apply → Save → **Build Now**

---

## 🔁 Setup GitHub Webhook

1. Go to GitHub Repo → **Settings** → **Webhooks** → Add Webhook
2. Payload URL: `http://<JENKINS_PUBLIC_IP>:8080/github-webhook/`
3. Content type: `application/json`
4. Event: **Just the push event**
5. Click **Add Webhook**

---

## ✅ Verify

Push a change to the repo and observe:

* Jenkins triggers a new pipeline run
* Console logs are visible under Build → Console Output
* Your app is rebuilt and deployed automatically 🎉

---

## 🔗 Connect with Me

I share content on:

* 🚀 DevOps
* 🎬 Vlogs
* 🧳 Travel stories
* 🎤 Contrafactums

👉 [Sagar Kakkala One Stop](https://linktr.ee/sagar_kakkalas_world)

Feel free to share feedback, queries, or suggestions in the comments!
