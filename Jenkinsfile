pipeline {
    agent any

        options {
        timestamps()
        skipDefaultCheckout()
        timeout(time: 5, unit: 'MINUTES')
    }
    
    stages {
        stage('Get code') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    echo 'Getting the repo'
                    git branch: 'main', url: 'https://github.com/carogarb/helloworld.git'
                    sh 'ls -la'
                    echo WORKSPACE                
                }
            }
        }
        
        stage('Unit tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    echo 'Running unit tests'
                    sh '''
                        export PYTHONPATH=.
                        pytest --junitxml=result-unit.xml --cov --cov-report=xml:coverage.xml test//unit
                    '''
                    junit 'result-unit.xml'
                }
            }
        }

        stage('Integration tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh '''
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
                            sh '''
                                export PYTHONPATH=.
                                pytest --junitxml=result-rest.xml test//rest
                            '''
                            junit 'result-rest.xml'
                        } else {
                            error 'Error starting flask or wiremock. Cannot run rest tests'
                        }

                    }
                }                            
            }
        } 

        stage('Static code analysis') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    echo 'Running flake8'
                    sh '''
                        export PYTHONPATH=.
                        flake8 --format=pylint --exit-zero app>flake8.out
                    '''

                    recordIssues tools:[flake8(name:'Flake8', pattern:'flake8.out')], healthy:8, unhealthy:10, qualityGates: [[threshold:8, type: 'TOTAL', unstable:true], [threshold:10, type:'TOTAL', unstable:true]]
                }    
            }
        }

       stage('Security tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    echo 'Running bandit'
                    sh '''
                        export PYTHONPATH=.
                        bandit --exit-zero -r . -f custom -o bandit.out --msg-template "{abspath}:{line}: [{test_id}] {msg}"
                    '''

                    recordIssues tools:[pyLint(name:'Bandit', pattern:'bandit.out')], healthy:2, unhealthy:4, qualityGates: [[threshold:2, type: 'TOTAL', unstable:true], [threshold:4, type:'TOTAL', unstable:true]]
                }                    
            }
        }

        stage('Performance tests') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    echo 'Running flask in background'
                            sh '''
                                export FLASK_APP=app//api.py
                                export FLASK_ENV=development
                                flask run &
                            '''

                    echo 'Running jmeter'
                    sh '''
                        jmeter -n -t test//jmeter//flask.jmx -f -l flask.jtl
                    '''

                    perfReport sourceDataFiles: 'flask.jtl'
                }                    
            }
        }

        stage('Code Coverage') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    echo 'Running coverage'
                    /*
                    sh '''
                        export PYTHONPATH=.
                        coverage run --branch --source=app --omit=app//__init__.py,app//api.py -m pytest test//unit
                        coverage xml
                    '''
                    */

                    cobertura coberturaReportFile: 'coverage.xml', conditionalCoverageTargets: '90,0,80', lineCoverageTargets: '95,0,85'
                }    
            }
        }
            
    }
    
    post {
        always {
            cleanWs()
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