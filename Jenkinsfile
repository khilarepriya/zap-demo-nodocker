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
          sh '''
            . venv/bin/activate
            nohup python3 app.py > app.log 2>&1 &
          '''
          sleep 10 // wait for app to be ready
        }
      }
    }

    stage('Run ZAP Scan') {
      steps {
        sh '''
          echo "⚙️ Starting ZAP scan on http://localhost:5010"

          /opt/zaproxy/zap.sh -cmd -quickurl http://localhost:5010 \
            -quickout zap_report.html -quickprogress -quickscan

          echo "✅ ZAP scan completed"
        '''
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

    stage('Show ZAP Report URL') {
      steps {
        echo "📄 ZAP Report available at: ${env.BUILD_URL}zap-dast-scan-report"
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

