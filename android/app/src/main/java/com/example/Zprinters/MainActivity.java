package com.example.Zprinters;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.zebra.sdk.comm.BluetoothConnection;
import com.zebra.sdk.comm.Connection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Set;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "surya432.rnd.dev/zebraprint";
    private static final String TAG = "MainActivity";
    private PrintUtils mPrintUtils;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            // TODO
                            System.out.println("FlutterZsdkPlugin registered with " + call.method);
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel();
                                if (batteryLevel != -1) {
                                    result.success(batteryLevel);
                                } else {
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            } else if (call.method.equals("getDevicesBluetooth")) {
                                JSONArray btDevices = getDevicesBluetooth();
                                System.out.println("FlutterZsdkPlugin registered with " + btDevices.toString());
                                if (btDevices.length() > 0) {
                                    result.success(btDevices.toString());
                                } else {
                                    result.error("UNAVAILABLE", "Printer tidak ditemukan.", null);
                                }
                            }else if(call.method.equals("sendCpclOverBluetooth")){
                                sendCpclOverBluetooth((String) call.argument("mac"), (String) call.argument("data"), result);
                            } else if (call.method.equals("printTest")) {
                                testPrint((String) call.argument("mac"), result);
                                result.success("OK Printer");
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void testPrint(String mac, MethodChannel.Result result) {
        try {
            mPrintUtils = PrintUtils.getInstance();
            mPrintUtils.setPrinter(mac);
            mPrintUtils.printNavigator("Bold");
            mPrintUtils.freePriner();
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private void sendCpclOverBluetooth(String mac, String data, MethodChannel.Result result) {
        try {
            Connection conn = new BluetoothConnection(mac);
            if(!conn.isConnected()){
                result.error("UNAVAILABLE","Tidak Bisa terhubung Ke printer",null);
            }
            Looper.prepare();

        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private JSONArray getDevicesBluetooth() {
        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            int REQUEST_ENABLE_BT = 10101;
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
        }
        Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
        JSONArray devices = new JSONArray();
        for (BluetoothDevice bt : pairedDevices) {
            try {
                JSONObject data = new JSONObject();
                data.put("name", bt.getName());
                data.put("mac", bt.getAddress());
                devices.put(data);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
//        Log.d("getDevicesBT:", "getDevicesBluetooth: " + devices.toString());
        return devices;
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }
}
