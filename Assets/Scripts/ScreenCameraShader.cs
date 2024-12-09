using UnityEngine;

public class ScreenCameraShader : MonoBehaviour
{
    [SerializeField] private Material m_renderMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, m_renderMaterial);
    }
}
