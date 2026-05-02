import media from '@ohos.multimedia.media';
import audio from '@ohos.multimedia.audio';
import { BusinessError } from '@kit.BasicServicesKit';

const audioFileCache: Map<string, media.AVFileDescriptor> = new Map();

class AudioPlaybackSession {
  private released: boolean = false;
  private readonly player: media.AVPlayer;
  private readonly filePath: string;
  private readonly audioManager: audio.AudioManager;
  private readonly sessionManager: audio.AudioSessionManager;
  private readonly volumeManager: audio.AudioVolumeManager;
  readonly errorHandler: (err: BusinessError) => void = (err: BusinessError): void => {
    this.handleError(err);
  };
  readonly stateChangeHandler: (state: media.AVPlayerState) => void = (state: media.AVPlayerState): void => {
    this.handleStateChange(state);
  };
  readonly audioInterruptHandler: (event: audio.InterruptEvent) => void = (event: audio.InterruptEvent): void => {
    this.handleAudioInterrupt(event);
  };
  readonly sessionDeviceChangeHandler: (event: audio.CurrentOutputDeviceChangedEvent) => void =
    (_event: audio.CurrentOutputDeviceChangedEvent): void => {
      this.handleDeviceChange();
    };
  readonly rendererDeviceChangeHandler: (event: audio.AudioStreamDeviceChangeInfo) => void =
    (_event: audio.AudioStreamDeviceChangeInfo): void => {
      this.handleDeviceChange();
    };
  readonly volumeChangeHandler: (event: audio.StreamVolumeEvent) => void = (event: audio.StreamVolumeEvent): void => {
    this.handleVolumeChange(event);
  };

  constructor(player: media.AVPlayer, filePath: string, audioManager: audio.AudioManager,
    sessionManager: audio.AudioSessionManager, volumeManager: audio.AudioVolumeManager) {
    this.player = player;
    this.filePath = filePath;
    this.audioManager = audioManager;
    this.sessionManager = sessionManager;
    this.volumeManager = volumeManager;
  }

  async prepareAndPlay(source: media.AVFileDescriptor): Promise<void> {
    this.player.audioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0
    };
    this.player.fdSrc = source;
    try {
      await this.player.prepare();
      await this.player.play();
    } catch (error) {
      console.error(`AVPlayer prepare or play failed for ${this.filePath}: ${error}`);
      await this.release();
    }
  }

  async release(): Promise<void> {
    if (this.released) {
      return;
    }

    this.released = true;
    this.detachListeners();
    try {
      await this.player.release();
    } catch (error) {
      console.error(`AVPlayer release failed: ${error}`);
    }
  }

  async stopPlayback(): Promise<void> {
    if (this.released) {
      return;
    }

    if (this.player.state === 'playing') {
      try {
        await this.player.pause();
      } catch (error) {
        console.error(`AVPlayer pause failed: ${error}`);
      }
    }

    await this.release();
  }

  private handleError(err: BusinessError): void {
    console.error(`AVPlayer error for ${this.filePath}: ${err}`);
    void this.release();
  }

  private handleStateChange(state: media.AVPlayerState): void {
    if (state === 'completed' || state === 'stopped' || state === 'released') {
      void this.release();
    }
  }

  private handleAudioInterrupt(event: audio.InterruptEvent): void {
    if (event.eventType !== audio.InterruptType.INTERRUPT_TYPE_BEGIN) {
      return;
    }

    if (event.hintType === audio.InterruptHint.INTERRUPT_HINT_PAUSE ||
      event.hintType === audio.InterruptHint.INTERRUPT_HINT_STOP ||
      event.hintType === audio.InterruptHint.INTERRUPT_HINT_MUTE) {
      void this.stopPlayback();
    }
  }

  private handleDeviceChange(): void {
    void this.stopPlayback();
  }

  private handleVolumeChange(event: audio.StreamVolumeEvent): void {
    if (event.volume <= 0) {
      void this.stopPlayback();
    }
  }

  private detachListeners(): void {
    this.player.off('error', this.errorHandler);
    this.player.off('stateChange', this.stateChangeHandler);
    this.player.off('audioInterrupt', this.audioInterruptHandler);
    try {
      this.sessionManager.off('currentOutputDeviceChanged', this.sessionDeviceChangeHandler);
    } catch (error) {
      console.error(`Failed to remove output device change listener: ${error}`);
    }
    try {
      this.player.off('audioOutputDeviceChangeWithInfo', this.rendererDeviceChangeHandler);
    } catch (error) {
      console.error(`Failed to remove renderer output device change listener: ${error}`);
    }
    try {
      this.volumeManager.off('streamVolumeChange', this.volumeChangeHandler);
    } catch (error) {
      console.error(`Failed to remove stream volume listener: ${error}`);
    }
  }
}

async function getAudioDescriptor(filePath: string, context: Context,
  fileCache: Map<string, media.AVFileDescriptor>): Promise<media.AVFileDescriptor> {
  const cached = fileCache.get(filePath);
  if (cached) {
    return cached;
  }

  try {
    const file = await context.resourceManager.getRawFd(filePath);
    const descriptor: media.AVFileDescriptor = {
      fd: file.fd,
      offset: file.offset,
      length: file.length
    };
    fileCache.set(filePath, descriptor);
    return descriptor;
  } catch (error) {
    console.error(`getAudioDescriptor failed for ${filePath}: ${error}`);
    throw new Error(`Failed to load audio descriptor for ${filePath}`);
  }
}

export async function preloadAudioFiles(context: Context, filePaths: string[]): Promise<void> {
  for (const filePath of filePaths) {
    try {
      await getAudioDescriptor(filePath, context, audioFileCache);
    } catch (error) {
      console.error(`preloadAudioFiles failed for ${filePath}: ${error}`);
    }
  }
}

export async function playAudio(filePath: string, context: Context): Promise<void> {
  let session: AudioPlaybackSession | null = null;
  try {
    const player: media.AVPlayer = await media.createAVPlayer();
    const audioManager = audio.getAudioManager();
    const sessionManager = audioManager.getSessionManager();
    const volumeManager = audioManager.getVolumeManager();
    session = new AudioPlaybackSession(player, filePath, audioManager, sessionManager, volumeManager);
    player.on('error', session.errorHandler);
    player.on('stateChange', session.stateChangeHandler);
    player.on('audioInterrupt', session.audioInterruptHandler);
    try {
      sessionManager.on('currentOutputDeviceChanged', session.sessionDeviceChangeHandler);
    } catch (error) {
      console.error(`Failed to register output device change listener: ${error}`);
    }
    try {
      player.on('audioOutputDeviceChangeWithInfo', session.rendererDeviceChangeHandler);
    } catch (error) {
      console.error(`Failed to register renderer output device change listener: ${error}`);
    }
    try {
      volumeManager.on('streamVolumeChange', audio.StreamUsage.STREAM_USAGE_MUSIC, session.volumeChangeHandler);
    } catch (error) {
      console.error(`Failed to register stream volume listener: ${error}`);
    }
    const descriptor = await getAudioDescriptor(filePath, context, audioFileCache);
    await session.prepareAndPlay(descriptor);
  } catch (error) {
    if (session) {
      await session.release();
    }
    console.error(`playAudio failed for ${filePath}: ${error}`);
  }
}
