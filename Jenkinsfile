pipeline {
    agent any
    stages {
        stage('Build on aks ') {
            steps {           
                        sh 'pwd'
                        sh '/usr/local/bin/helm upgrade --install python-restapi-app /var/lib/jenkins/test'
                          
            }           
        }
    }
}