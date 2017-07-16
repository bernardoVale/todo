#!groovy

@Library('pipeline')
def pipe = new com.avenuecode.pipeline.Utils()
          

node('ac-release-website'){
    checkout scm
    gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
    branchName = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
    def appColor = pipe.getColor('todo')
    println "Current color: ${appColor}"
    

    stage('Build'){
      app = docker.build("bernardovale/todo-app:$gitCommit", "--build-arg APP_VERSION=$gitCommit $WORKSPACE")
    }
    stage('Unit Tests'){
        docker.image('mongo').withRun(){ m ->
          app.inside("-e MONGODB_HOST=mongo -e APP_ENV=staging --link ${m.id}:mongo"){
            sh 'pytest tests/functional --junit-xml results/functional.xml'
            junit '**/results/functional.xml'
          }
        }
    }
    stage('Publish'){
      docker.withRegistry("https://index.docker.io/v1/", 'registry-bvale') {
        app.push()
      }
    }
    if (env.BRANCH_NAME == "master" ) {
      stage('Deploy'){
        newColor = (appColor == 'green') ? 'blue' : 'green'
        println "Updating todo app to version:${gitCommit} on color: ${newColor}"
        sh " sed \"s/__VERSION__/$gitCommit/g\" deploy/${newColor}.yml | kubectl apply -f - "
      }
      stage('Smoke Tests'){
        dir('tests/acceptance'){
          try{
            sh 'docker-compose build'  
            sh "URL=https://todo-${newColor}.avenuecode.com docker-compose run --rm cuchromer features"
          }finally{
            sh 'docker-compose down'
          }
        }
      }
      // stage('Approval'){
      //   input message: 'Switch application color?', ok: 'Yes!'
      // }
      stage('Switch'){
        pipe.switchOver('todo')
      }
    }
}