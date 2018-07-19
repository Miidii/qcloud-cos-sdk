pipeline {
  agent any
  stages {
    stage('bundle') {
      steps {
        sh 'bundle'
      }
    }
    stage('build') {
      steps {
        sh 'gem build qcloud-cos-sdk'
      }
    }
  }
}