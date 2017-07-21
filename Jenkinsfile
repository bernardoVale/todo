#!groovy

@Library('pipeline')
// Instantiating ac library with application name
def pipe = new com.avenuecode.kubernetes.Pipeline('todo')
def deployFrom = (env.BRANCH_NAME == 'develop') ? 'staging' : 'production'
          

node('ac-release-website'){
    checkout scm

    println "Current commit: ${pipe.commit}"
    println "Current color: ${pipe.color}"
    // Sets ingress environment
    pipe.environment = deployFrom

    stage('Build'){
      app = docker.build("bernardovale/todo-app:${pipe.commit}", "--build-arg APP_VERSION=${pipe.commit} $WORKSPACE")
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
        println "Updating todo app to version:${pipe.commit} on color: ${pipe.next}"
        sh "sed \"s/__VERSION__/${pipe.commit}/g\" deploy/${deployFrom}/${pipe.next}.yml | kubectl apply -f - "
      }
      stage('Smoke Tests'){
        dir('tests/acceptance'){
          try{
            sh 'docker-compose build'  
            sh "URL=https://todo-${pipe.next}.avenuecode.com docker-compose run --rm cuchromer features"
          }finally{
            sh 'docker-compose down'
          }
        }
      }
      // stage('Approval'){
      //   input message: 'Switch application color?', ok: 'Yes!'
      // }
      stage('Switch'){
        pipe.switchOver()
      }
    }
}