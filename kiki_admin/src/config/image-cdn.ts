/** 管理后台图片 CDN 的唯一配置入口。 */
export const IMAGE_CDN_HOST = 'img.keepthinking.me'
export const IMAGE_CDN_ORIGIN = `https://${IMAGE_CDN_HOST}`

/** 数据库中仍可能存在的历史域名，仅用于识别并迁移到当前域名。 */
export const LEGACY_IMAGE_CDN_HOSTS = ['img.mtrain.xyz'] as const

export function isImageCDNHost(hostname: string): boolean {
  const normalizedHost = hostname.toLowerCase()
  return normalizedHost === IMAGE_CDN_HOST
    || LEGACY_IMAGE_CDN_HOSTS.some(host => host === normalizedHost)
}

export function buildImageCDNUrl(key: string): string {
  return `${IMAGE_CDN_ORIGIN}/${key.replace(/^\/+/, '')}`
}
