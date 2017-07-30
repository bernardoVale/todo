#!groovy

@Library('commons')
// Instantiating ac library with application name
def pipe = new com.avenuecode.kubernetes.Pipeline('todo')
import com.avenuecode.tag.Tag

node('ac-release-website'){
    // Checkout sending the result variable to Tag class
    def scmVar = checkout scm
    def tag = new Tag(this, scmVar)
    
    println "Current color: ${pipe.color}"
    // Sets ingress environment
    pipe.environment = 'default'

    // Use git commit unless we're running on master branch
    version = (env.BRANCH_NAME == 'master') ? tag.next : tag.scm.GIT_COMMIT

    stage('Build'){
      app = docker.build("bernardovale/todo-app:${version}", "--build-arg APP_VERSION=${version} $WORKSPACE")
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
        stage('Tag'){
            tag.push() // Push Tag to Gitlab
        }
        stage('Deploy'){
            println "Updating todo app to version:${version} on color: ${pipe.next}"
            sh "sed \"s/__VERSION__/${version}/g\" deploy/${pipe.environment}/${pipe.next}.yml | kubectl apply -f - "
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
        stage('Switch'){
            pipe.switchOver()
        }
    }
}