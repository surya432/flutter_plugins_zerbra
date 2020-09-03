package com.example.Zprinters;

import android.os.Parcel;
import android.os.Parcelable;

public class ModelDeviceBluetooth implements Parcelable {
    public static final Parcelable.Creator<ModelDeviceBluetooth> CREATOR = new Parcelable.Creator<ModelDeviceBluetooth>() {
        @Override
        public ModelDeviceBluetooth createFromParcel(Parcel source) {
            return new ModelDeviceBluetooth(source);
        }

        @Override
        public ModelDeviceBluetooth[] newArray(int size) {
            return new ModelDeviceBluetooth[size];
        }
    };
    String name;
    String mac;

    public ModelDeviceBluetooth(String name, String mac) {
        this.name = name;
        this.mac = mac;
    }

    protected ModelDeviceBluetooth(Parcel in) {
        this.name = in.readString();
        this.mac = in.readString();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getMac() {
        return mac;
    }

    public void setMac(String mac) {
        this.mac = mac;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.name);
        dest.writeString(this.mac);
    }
}
