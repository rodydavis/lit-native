package com.example.app

import android.os.Bundle
import android.view.ViewGroup
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.viewinterop.AndroidView
import com.example.app.ui.theme.AppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AppTheme {
                Screen("Android")
            }
        }
    }
}

@Composable
fun Screen(title: String) {
    AndroidView(
        modifier = Modifier.fillMaxSize(), // Occupy the max size in the Compose UI tree
        factory = {
            WebView(it).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
                webViewClient = WebViewClient()
                settings.allowContentAccess = true
                settings.allowFileAccess = true
                val tag = "my-element"
                val slot = ""
                val script = "build/bundle.es.js"
                loadData("""
            <!DOCTYPE html>
            <html lang="en">
              <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no" />
                <title>${title}</title>
                <style>
                    body {
                        width: 100%;
                        height: 100vh;
                        padding: 0;
                        margin: 0;
                    }
                </style>
              </head>
              <body>
                <${tag}>
                    $slot
                </${tag}>
                <script src="file://android_asset/${script}"></script>
              </body>
            </html>
                """.trimIndent(), "text/html", "UTF-8")
//                loadUrl("https://google.com")
            }
        },
        update = {

        }
    )
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    AppTheme {
        Screen("Android")
    }
}