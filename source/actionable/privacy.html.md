---
title: Actionable Privacy Policy
---

_Last updated: September 11, 2026_

Actionable does not collect, store, transmit, or share any personal data. Your meetings stay
on your own devices, and I have no way to read them.

## The microphone

Actionable listens through the microphone and transcribes what it hears on the device. The
audio is never written to a file. It is held in memory long enough to be recognized and then
it is gone, so there is no recording of your meeting anywhere, not even on your own disk.

Telling voices apart happens on the device too, and the app learns nothing about a voice that
outlives the meeting. Pulling out the action items uses Apple Intelligence, which also runs on
the device.

## It keeps listening when you leave it

On an iPhone or iPad, Actionable declares the audio background mode, so pressing Listen opens
the microphone and leaves it open. Switch to another app and it is still listening. Lock the
screen and it is still listening. Nothing in the app closes the microphone when Actionable
stops being the app in front of you, and no timer closes it either. On a Mac it is the same:
the meeting carries on with the window behind something else.

Two things end a meeting. You press Stop, or the speech pipeline fails and the app says on
screen that transcription stopped. That is the whole list. If a phone call or Siri interrupts,
Actionable picks the meeting up again by itself once the interruption is over. While a meeting
is running the screen is also held awake, so it does not lock on its own.

It works this way because a meeting does not pause when you put the phone down to write
something. It does mean the app can be listening when you are not looking at it, which is why
a rising two-note tone plays when the microphone opens and a falling one when it closes: so
everyone in the room hears it start and stop, not only whoever can see the screen. Everything
else in this policy still holds while the app is in the background. Nothing is written to a
file and nothing leaves the device.

## Speech recognition never leaves the device

Two speech engines run side by side, and both are held to the device.

The accurate one is Apple's SpeechAnalyzer, and its text is the only text the app keeps. It
uses the speech model for your language that the operating system downloads once and runs
here. If a device cannot run that, Actionable does not start the meeting at all: it says
on-device speech transcription is not available on this device, and stops. There is no server
mode to fall back to, and no code in the app that could ask for one.

The second engine drives the live caption you watch while somebody is still talking.
Actionable sets it up only if this device can recognize speech on-device, and every request it
makes is marked as requiring on-device recognition. On a device that cannot, there is no live
caption and the accurate engine carries on by itself.

So no path through the app sends your words away to be recognized, including the paths that
run when a recognition task fails and starts over.

## Your calendar

When you press Listen, Actionable reads the calendar event happening now to fill in the
meeting title and the attendees, which saves you typing them. It only reads, on the device,
and it never changes your calendar. You can withdraw its access at any time in Privacy &
Security settings.

## What is kept, and where

Your meetings, on your device: the transcript, the action items with their owners and due
dates, the attendees, and which voice said which line. They are there so you can read a
meeting months later and search every word of it.

## iCloud

If you are signed in to iCloud, your meetings sync between your own devices through **your**
iCloud account, in its private database, and each is written out as a Markdown file in your
own iCloud Drive, readable in Finder or the Files app. It is your iCloud, under your own Apple
Account, and I cannot reach it. Signed out, everything stays on the one device.

## Network

Actionable makes no network requests of its own. It has no analytics, no advertising, no
accounts, and no third-party services.

Two downloads happen on first run, both of software rather than of anything about you:
Apple's speech model for your language, fetched by the operating system, and the speaker
separation model, fetched once from huggingface.co. Nothing from a meeting is in either
request. As with any download, the server sees that some device asked for a file, so it sees
an IP address. Neither happens again after the first run.

## Contact

Questions about this policy: email me at <alex@alexecollins.com>.

Help with the app itself is on the
[support page](/actionable/support.html).
