pipeline {
	agent any
    stages {
        stage('Build on aks ') {
            steps {           
                        sh 'pwd'
                        sh 'cp -R test .'
						sh 'ls -ltr'
                        sh 'pwd'
                        sh '/usr/local/bin/helm install python-restapi-app /var/lib/jenkins/jobs/test'
              			
            }           
        }
    }
}