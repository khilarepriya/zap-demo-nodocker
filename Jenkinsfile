pipeline {
  agent any

  environment {
    PYTHONPATH = "${WORKSPACE}"
    ZAP_REPORT = "zap_report.html"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/khilarepriya/zap-demo-nodocker.git'
      }
    }

    stage('Install Dependencies') {
      steps {
        sh '''
          python3 -m venv venv
          . venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt
        '''
      }
    }

    stage('Start Web App') {
      steps {
        script {
          // Run in background
          sh 'nohup python3 app.py &'
          sleep 10 // wait for app to be ready
        }
      }
    }

    stage('Run ZAP Scan') {
      steps {
        sh './zap_scan.sh'
      }
    }

    stage('Publish ZAP Report') {
      steps {
        publishHTML([
          allowMissing: false,
          alwaysLinkToLastBuild: true,
          keepAll: true,
          reportDir: '.',
          reportFiles: 'zap_report.html',
          reportName: 'ZAP DAST Scan Report'
        ])
      }
    }
  }

  post {
    always {
      sh 'pkill -f app.py || true'
      archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
    }
  }
}
