# iOS Media Re-encoder

This is a bulk file management utility, specifically designed for re-encoding iOS media files (photos, videos...) from your Apple device, which sometimes get bigger than we would want them to.

> [!IMPORTANT]
> This is not an all-user friendly utility, as a minimal IT knowledge is required (opening a command line interface, run some scripts, etc.). However, this README file aims to explain the process in the simplest way possible.

## Use case

This utility was born out of a issue I ran into, which is probably relatable for almost any iOS user: I was running out of space in iCloud. It seems like recording your cat's adventures in 4K60FPS is not the ideal way to keep those memories for your device storage. Due to this, I decided to re-encode my videos to 1080p30FPS format, then I saw 2.5GB videos turning into 80MB ones while keeping most of their details and decided this was the way to go.

## Other issues

After my first attempt at solving the problem described before, I noticed that there were other factors to take into account, such as:

- Creation and modification dates being overwritten during file transfer between the device and the PC
- Modification date remaining untouched while creation date was set to the file transfer date
- Both dates being changed after re-encoding media (as a result of generating a new re-encoded version of the file)

But there's no need to worry, as I managed to find a solution to all these issues. And by the way, if you wonder why dates are so relevant, imagine having recorded some videos in 2022, re-encoding them and observing they suddenly became the most recent media in your gallery. Not ideal, right? So let's keep the dates, as they are pretty relevant to Apple Photos.

## Installation

Installing this utility is really simple: you just need to head to the latest release, take a look into the attached files and download the one named `ios-media-re-encoder.ps1`, which is a script that contains all the code logic.

There are also two pre-requisites: [`ffmpeg`](https://www.ffmpeg.org/) and [`HandBrakeCLI`](https://handbrake.fr/downloads2.php) (from the [HandBrake](https://handbrake.fr/) utility). They can easily be installed using [Chocolatey](https://community.chocolatey.org/) through a PowerShell command line terminal **in administrator mode**:

```ps1
choco install -y ffmpeg handbrake-cli
```

If you can't or won't use Chocolatey, you will need to manually download both utilities, but remember to alias them under `ffmpeg` and `HandBrakeCLI`, respectively, or the media re-encoder utility will fail.

> [!WARNING]
> Remember to close and re-open your command line interface terminal after installing any packages or commands, as they sometimes are not available until refreshing source code. You can test both commands by running `ffmpeg` and `HandBrakeCLI` in your command line terminal.

## Usage

Let's break down usage in several steps:

### 1. Copy your media files from the iOS device to the PC

First of all, you will need to copy your media files from the iOS device to the PC. I personally recommend adding the files you want to re-encode to an album for future reference (as this will be useful for [step 5](#5-cleanup-actions))

In order to avoid messing up the dates on the files, you should plug in your device and access the files using Windows Explorer. After finding each file, just drag and drop it to a folder of your choosing. Don't worry, this will not remove the file from your device, but rather just copy it.

### 2. Locate the files in a dedicated directory

In order to avoid unexpected behavior and isolating your files, you should create a dedicated folder for them (go ahead and name it `asdasdasd` if you want, it does not matter). Then, copy the path for that **folder** (not the files!) and keep it in your clipboard, as you will need it later on.

### 3. Run the utility

Open up a PowerShell command line terminal and run the tool by calling the path to the executable file you set up during the [installation](#installation) step, then paste the path to the folder you copied in the previous step. Remember to wrap both paths in double quotes to avoid potential syntax errors. Your command should then look similar to this:

```powershell
"C:\Users\YourUser\...\ios-media-re-encoder.ps1" "C:\Users\YourUser\...\MyMediaFromDevice"
```

When you hit enter, the utility will execute and iterate over each media file re-encoding it and processing all data. You might see some temporal files being created, but don't worry, as they will automatically be cleaned up after the process finishes.

### 4. Copy the new files back to the device

Once all files have been processed, you will need to copy them back to the device, but this might not be as straightforward as it looks: depending on the transfer method you perform, media dates might get twisted up, and we do not want that at all.

My personal solution is the following:

1. Connect your device via USB cable to the PC
2. Access it through iTunes (you will probably need to allow it and reconnect it if it does not work the first time)
3. Go to the `File Sharing` tab in the device panel in iTunes
4. Use some application that allows shared storage (i.e. Google Chrome, VLC, etc.) to drag and drop the re-encoded media
5. Wait for the whole operation to finish
6. In your device, open the Files app and navigate to the shared storage folder where you shared the media
7. Select all transfered files, hit the share button, then select `Save to Photos`
8. Done! You can then delete the media from the Files app, as it has been successfully copied to your gallery

### 5. Cleanup actions

Remember that note about creating an album in [step 1](#1-copy-your-media-files-from-the-ios-device-to-the-pc)? This is where it becomes useful, as if you created it and successfully re-encoded and tranfered all those files, you can just go ahead, select the whole album and delete it. This will delete the originals, but you can always double-check that the new media is already in your gallery by opening options for each of the files in the album and pressing `Show in All Photos`. Then, you should see a duplicate of that file, where one of them is the original and the other, the re-encoded result.

## Thanks

That's it, thank you for using this utility. Hope it saved you some time, and if so, feel free to drop a star on this repo!

## License

This repository and all its contents are registered under the [GNU Affero General Public License v3.0](./LICENSE).
