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
