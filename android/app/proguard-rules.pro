## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**
-keep class androidx.lifecycle.** { *; }

## Gson rules
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

-ignorewarnings
-printconfiguration proguard-merged-config.txt
-dontpreverify
-verbose
-allowaccessmodification
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses

-keepnames class **
-keep ,allowshrinking,allowoptimization class **.R
-keep ,allowshrinking,allowoptimization class **.R$*
-keepclassmembers class **.R.** { <fields>;}
-keepclassmembers class **.R$* { <fields>;}

-keepattributes Signature,*Annotation*,Annotation,EnclosingMethod,InnerClasses

-keep ,allowshrinking,allowoptimization class ali.imports.MyClasses.ViewSection.** { *; }

# Parcelable
-keepclassmembers class * implements android.os.Parcelable {static ** CREATOR;}
-keepclassmembers class * implements java.io.Serializable {*;}
-keepclassmembers class * extends java.lang.Enum {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Views
-keep ,allowshrinking,allowoptimization class * extends android.view.View {*;}
-keep ,allowshrinking,allowoptimization class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Others
-keep ,allowshrinking,allowoptimization class * extends java.lang.Exception
-keep ,allowshrinking,allowoptimization class * extends android.app.Service
######################################################################################################
######################################################################################################
## flutter_local_notification plugin rules
-keep class com.dexterous.** { *; }
