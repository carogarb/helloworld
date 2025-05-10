pipeline {
    agent any
    
    stages {
        stage('Get code') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    echo 'Getting the repo'
                    git branch: 'develop', url: 'https://github.com/carogarb/helloworld.git'
                    sh 'ls -la'
                    echo WORKSPACE                
                }
            }
        }
        
        stage('Build code') {
            steps {
                echo 'Not needed with python'
            }
        }
        
        stage('Run tests') {
            parallel {
                
                stage('Unit tests') {
                    steps {
                        echo 'Running unit tests'
                        sh '''
                            export PYTHONPATH=.
                            pytest --junitxml=result-unit.xml test//unit
                        '''
                    }
                }
                
                stage('Rest tests') {
                    steps {
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            echo 'Running flask in background'
                            sh '''
                                export FLASK_APP=app//api.py
                                export FLASK_ENV=development
                                flask run &
                            '''
                            
                            echo 'Running wiremock in background'
                            sh 'java -jar /opt/wiremock/wiremock-standalone.jar --port 9090 --root-dir /opt/wiremock > wiremock.log 2>&1 &'
                            
                            // Wait until wiremock and flask are up
                            sleep(time:60, unit:"SECONDS")
                        
                            echo 'Running rest tests'
                            sh '''
                                export PYTHONPATH=.
                                pytest --junitxml=result-rest.xml test//rest
                            '''
                        }    
                    }
                }
            }
        }
        
        stage('Results') {
            steps {
                junit 'result*.xml'
            }
        }
            
    }
    
    post {
        always {
            cleanWs()
        }
    }
}