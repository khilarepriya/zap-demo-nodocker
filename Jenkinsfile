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
        sh '''
          . venv/bin/activate

          echo "🚀 Starting Flask app..."
          nohup python app.py > app.log 2>&1 &
          APP_PID=$!

          echo "⏳ Waiting for app to start..."
          for i in {1..10}; do
            if curl -s http://localhost:5010 >/dev/null; then
              echo "✅ App is up!"
              exit 0
            fi
            echo "⏳ Still waiting..."
            sleep 2
          done

          echo "❌ App did not start in time."
          echo "📜 Logs:"
          cat app.log || echo "⚠️ No app.log found"
          kill $APP_PID
          exit 1
        '''
      }
    }

    stage('Run ZAP Scan') {
      steps {
        sh '''
          echo "⚙️ Starting ZAP scan on http://localhost:5010"

          /opt/zaproxy/zap.sh -cmd \
            -port 8091 \
            -quickurl http://localhost:5010 \
            -quickout zap_report.html \
            -quickprogress

          echo "✅ ZAP scan completed"
          ls -lh zap_report.html || echo "⚠️ Report not found"
          cat zap_report.html || echo "⚠️ Report is empty"
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

