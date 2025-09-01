# Patient Booking App

## Requirements
- riverpod: for managing states
- flutter_riverpod
- hive: database for persistence
- hive_flutter
- uuid: unique identifiers
- intl: date and number formatting
- flutter_local_notifications: allows the app to display alerts
- carousel_slider: for the onboarding screen
- timezone: used to schedule notifications at a certain time (1 hour before appointment)

## How To Run

```
git clone https://github.com/lasersig/appointmentapp.git
flutter pub get
flutter pub run build_runner build        # these files are already generated
flutter run
```

## Video Demo

<iframe width="560" height="315" src="https://youtu.be/Bb5U6teBWFM" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Flows

### Splash Screen
![Splash Scren](flows/splashscreen.png)
### Onboarding(1, 2, 3)
![Onboarding1](flows/Onboarding1.png)
![Onboarding2](flows/Onboarding2.png)
![Onboarding3](flows/Onboarding3.png)
### Sign In
![Sign In](flows/SignIn.png)
### OTP
![OTP](flows/OTP.png)
### Complete Profile (Optional)
![Complete Profile](flows/OptionalCompleteProfile.png)
### Upcoming Appointments
![Upcoming Appointments](flows/UpcomingAppointments.png)
### Missed Appointments
![Missed Appointments](flows/MissedAppointments.png)
### Completed Appointments
![Completed Appointments](flows/CompletedAppointments.png)
### Search Doctors
![Search Doctors](flows/SearchDoctors.png)
### Filters
![Filter Doctors](flows/FilterDoctors.png)
![Specialties](flows/DoctorSpecialities.png)
### Doctor Profile After Selecting a Doctor
![Doctor Profile](flows/DoctorProfile.png)
### Select Date and Time For Appointment (cannot book past dates)
![Select Date](flows/SelectDateAndTimeForAppointment.png)
### Select Time Slot
![Select Time Slot](flows/SelectTimeSlot.png)
![Selected Time](flows/SelectedTime.png)
### Confirm Booking
![Confirm Booking](flows/ConfirmBooking.png)
### Notification
![Notification](flows/Notifications.png)
### Appointment Details
![Appointment Details](flows/AppointmentDetails.png)
### Confirm Reschedule
![Confirm Reschedule](flows/ConfirmReschedule.png)
### Confirm Cancel
![Confirm Cancel](flows/ConfirmCancel.png)
### Account Screen
![Account Screen](flows/AccountScreen.png)
### Sign In As Doctor
![Sign In Doctor](flows/SignInAsDoctor.png)
### Manage Schedule Button From Account Screen
![Manage Button](flows/ManageScheduleButton.png)
### Simple Doctor Dashboard
![Doctor Dashboard](flows/SimpleDoctorDashboard.png)
