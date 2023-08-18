# -*- coding: utf-8 -*-

import datetime
import numpy as np
import pyautogui
import imageio
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from threading import Thread
from PIL import Image, ImageDraw
import time

class ScreenRecorderApp:
    # Initialize the user interface components
    def __init__(self, root):
        # Initialize the main window
        self.root = root
        self.root.title("Screen Recorder")
        self.output_folder = ""

        # Default settings for recording
        self.frame_rate = 24
        self.frame_interval = 1 / self.frame_rate
        self.is_recording = False
        self.start_time = None

        # Set the window size
        self.root.geometry("400x400")

        # Create UI elements
        self.title_label = tk.Label(self.root, text="Screen Recorder", font=("Comic Sans MS", 18, "bold"), bg="lightblue", fg="navy", width= 400)
        self.title_label.pack(pady=10)
        button_width = 15
        self.choose_folder_button = tk.Button(self.root, text="Chọn nơi lưu", command=self.choose_output_folder, font=("Comic Sans MS", 10))
        self.choose_folder_button.pack(pady=5)

        self.selected_folder_label = tk.Label(self.root, text="Nơi lưu:", font=("Comic Sans MS", 10))
        self.selected_folder_label.pack(pady=2)

        self.selected_folder_var = tk.StringVar()
        self.selected_folder_entry = tk.Entry(self.root, textvariable=self.selected_folder_var, font=("Comic Sans MS", 10), state=tk.DISABLED)
        self.selected_folder_entry.pack(pady=2)

        self.frame_rate_label = tk.Label(self.root, text="Chọn tốc độ khung hình (Có thể tuỳ chỉnh):", font=("Comic Sans MS", 10))
        self.frame_rate_label.pack(pady=2)

        self.frame_rate_options = [24, 30, 60]
        self.selected_frame_rate = tk.IntVar(value=self.frame_rate_options[0])

        self.frame_rate_option_menu = ttk.Combobox(self.root, textvariable=self.selected_frame_rate, values=self.frame_rate_options)
        self.frame_rate_option_menu.pack(pady=2)

        self.start_button = tk.Button(self.root, text="Bắt đầu ghi", command=self.start_recording, font=("Comic Sans MS", 12), width=button_width, bg="white", fg="green")
        self.start_button.pack(pady=5)

        self.stop_button = tk.Button(self.root, text="Dừng ghi", command=self.stop_recording, state=tk.DISABLED, font=("Comic Sans MS", 12), width=button_width, bg="white", fg="red")
        self.stop_button.pack(pady=5)

        self.elapsed_time_label = tk.Label(self.root, text="Thời gian đã ghi: 00:00:00", font=("Comic Sans MS", 20, "bold"),fg= "red")
        self.elapsed_time_label.pack(pady=2)

    # Method to choose the output folder
    def choose_output_folder(self):
        selected_folder = filedialog.askdirectory()
        if selected_folder:
            self.output_folder = selected_folder
            self.selected_folder_var.set(selected_folder)

    # Method to start recording
    def start_recording(self):
        if not self.output_folder:
            messagebox.showinfo("Lỗi", "Vui lòng chọn nơi lưu trước khi ghi.")
            return

        if not self.is_recording:
            self.is_recording = True
            self.start_button.config(state=tk.DISABLED)
            self.stop_button.config(state=tk.NORMAL)
            self.frame_rate = self.selected_frame_rate.get()
            self.frame_interval = 1 / self.frame_rate
            self.start_time = datetime.datetime.now()
            self.start_recording_thread()

    # Method to stop recording
    def stop_recording(self):
        self.is_recording = False
        self.start_time = None
        self.stop_button.config(state=tk.DISABLED)
        self.start_button.config(state=tk.NORMAL)

    # Method to start recording thread
    def start_recording_thread(self):
        self.time_stamp = datetime.datetime.now().strftime('%Y-%m-%d %H-%M-%S')
        self.file_name = f'{self.time_stamp}.mp4'
        self.full_file_path = f'{self.output_folder}\\{self.file_name}'

        self.screen_width, self.screen_height = pyautogui.size()
        self.video_writer = imageio.get_writer(self.full_file_path, fps=self.frame_rate,
                                               codec='libx265', quality=8, pixelformat='yuv444p',
                                               ffmpeg_params=['-preset', 'medium'])
        self.recording_thread = Thread(target=self.record)
        self.recording_thread.start()

    # Method to create an image of a circular cursor with black border and yellow color
    def create_cursor_image(self, radius, color):
        cursor_image = Image.new("RGBA", (radius * 2, radius * 2))
        draw = ImageDraw.Draw(cursor_image)

        # Draw a black circular border
        draw.ellipse((0, 0, radius * 2, radius * 2), fill=(0, 0, 0, 128))
        # Draw a yellow circular shape inside
        inner_radius = radius - 2
        draw.ellipse((2, 2, inner_radius * 2 + 2, inner_radius * 2 + 2), fill=color)

        return cursor_image
    
    # Method to record the screen with a mouse cursor
    def record(self):
        cursor_radius = 7
        cursor_color = (255, 255, 0, 192)
        try:
            while self.is_recording:
                start_frame_time = time.time()
                screenshot = pyautogui.screenshot(region=(0, 0, self.screen_width, self.screen_height))
                img_np = np.array(screenshot)

                mouse_x, mouse_y = pyautogui.position()
                cursor_img = self.create_cursor_image(cursor_radius, cursor_color)
                cursor_width, cursor_height = cursor_img.size
                cursor_np = np.array(cursor_img)
                cursor_mask = cursor_np[:, :, 3] > 0
                cursor_rgb = cursor_np[:, :, :3]
                img_np[mouse_y:mouse_y + cursor_height, mouse_x:mouse_x + cursor_width, :][cursor_mask] = cursor_rgb[cursor_mask]
                self.video_writer.append_data(img_np)
                end_frame_time = time.time()
                frame_duration = end_frame_time - start_frame_time
                sleep_time = max(0, self.frame_interval - frame_duration)
                time.sleep(sleep_time)

                if self.start_time:
                    elapsed_time = datetime.datetime.now() - self.start_time
                    hours, remainder = divmod(elapsed_time.seconds, 3600)
                    minutes, seconds = divmod(remainder, 60)
                    elapsed_time_str = f"{hours:02}:{minutes:02}:{seconds:02}"
                    self.elapsed_time_label.config(text=f"Thời gian đã ghi: {elapsed_time_str}")

        except KeyboardInterrupt:
            pass

        finally:
            self.video_writer.close()

# Initialize the GUI and the application
if __name__ == "__main__":
    root = tk.Tk()
    app = ScreenRecorderApp(root)
    root.mainloop()
