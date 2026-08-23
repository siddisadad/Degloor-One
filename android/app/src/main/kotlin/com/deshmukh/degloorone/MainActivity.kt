package com.deshmukh.degloorone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.deshmukh.degloorone.services.ServiceMarketplaceBridge
import com.deshmukh.degloorone.services.DiscoveryBridge

class MainActivity: FlutterActivity() {
    private val SERVICE_CHANNEL = "com.deshmukh.degloorone/services"
    private val DISCOVERY_CHANNEL = "com.deshmukh.degloorone/discovery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SERVICE_CHANNEL).setMethodCallHandler(
            ServiceMarketplaceBridge()
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DISCOVERY_CHANNEL).setMethodCallHandler(
            DiscoveryBridge()
        )
    }
}
