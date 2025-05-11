pipeline {
    agent none

    options {
        timestamps()
        parallelsAlwaysFailFast()
        timeout(time: 5, unit: 'MINUTES')
    }

    stages {
 
        stage('Checkout code') {
                agent {
                    label 'agent1'
                }
                steps {
                    catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                        sh 'hostname'
                        git branch: 'feature_fix_racecond', url: 'https://github.com/carogarb/helloworld.git'
                        stash name: 'source', includes: '**'                   
                    }
                }
            }

        stage('Build code') {
                agent {
                    label 'agent2'
                }
                steps {
                    sh 'hostname'
                    echo 'Not needed with python'
                }
            }
                
        stage('Run tests') {
            parallel {

                stage('Unit tests') {
                    agent {
                        label 'agent1'
                    }
                    steps {
                        unstash 'source'
                        sh '''
                            hostname
                            export PYTHONPATH=.
                            pytest --junitxml=result-unit.xml test//unit
                        '''
                        stash name: 'unit-test', includes: 'result-unit.xml' 
                    }
                }                

                stage('Integration tests') {
                    agent {
                        label 'principal'
                    }
                    steps {
                        catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                            sh '''
                                hostname
                                export FLASK_APP=app//api.py
                                export FLASK_ENV=development
                                flask run &
                            '''
                            
                             sh 'java -jar /opt/wiremock/wiremock-standalone.jar --port 9090 --root-dir /opt/wiremock > wiremock.log 2>&1 &'

                            script {
                                // Wait until wiremock and flask are up
                                def flaskStatusCode = retryUntilRedinessOrMaxAttemps(
                                    url: 'http://127.0.0.1:5000/'    
                                )
                            
                                def wiremockStatusCode = retryUntilRedinessOrMaxAttemps(
                                    url: 'http://127.0.0.1:9090/calc/sqrt/64'    
                                )
                
                                if (flaskStatusCode == '200' && wiremockStatusCode == '200') {
                                    unstash 'source'
                                    sh '''
                                        hostname
                                        export PYTHONPATH=.
                                        pytest --junitxml=result-rest.xml test//rest
                                    '''
                                    stash name: 'integration-test', includes: 'result-rest.xml' 
                                } else {
                                    error 'Error starting flask or wiremock. Cannot run rest tests'
                                }

                            }
                        }                            
                    }
                } 
                              
            }
        }
        
         stage('Results') {
            agent {
                    label 'agent2'
            }
            steps {
                unstash 'unit-test'
                unstash 'integration-test'
                sh 'hostname'
                junit 'result*.xml'
            }
        }
            
    }
   
    post {
        always {
            node('agent1') {
                cleanWs()
            }
        }
    }
    
}

def retryUntilRedinessOrMaxAttemps(Map params) {
    def url = params.url
    def maxAttempts = params.maxAttemps ?: 10
    def waitTime = params.waitTime ?: 2 // seconds
    
    def statusCode
    for (int i = 1; i <= maxAttempts; i++) {
        try {
            echo "Attempting ${i} to call to ${url}"
            
            statusCode = sh (
                script: "curl -s -o /dev/null -w '%{http_code}' ${url}",
                returnStdout: true
            ).trim()
            
            if (statusCode == "200") {
                echo "Success"
                return statusCode
            } else {
                echo "Received status code ${statusCode}"
                sleep(waitTime)
            }
        } catch (Exception e) {
            echo "Error message: ${e.message}"
            sleep(waitTime)
            currentBuild.result = 'SUCCESS' // Ignore this error
        }    
    }
    
    return statusCode
}