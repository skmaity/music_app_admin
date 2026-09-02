{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      canvasKitBaseUrl: 'canvaskit/',
    });
    await appRunner.runApp();
    document.getElementById('loading')?.remove();
  },
}).catch((error) => {
  console.error(error);
  document.getElementById('loading').textContent =
    'Nyro could not start. Please refresh the page.';
});
